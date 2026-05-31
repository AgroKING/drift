import json
import logging
from pathlib import Path
from datetime import datetime, timezone
from typing import Any

from .coral_client import CoralClient
from .insight_generator import generate_insight
from drift_logic.report import build_drift_report
from drift_logic.models import DriftReport

logger = logging.getLogger(__name__)


def parse_iso_dt(s: str) -> datetime:
    return datetime.fromisoformat(s.replace("Z", "+00:00"))


def calculate_days_ago(dt_or_str: Any, now: datetime) -> int:
    if isinstance(dt_or_str, str):
        dt = parse_iso_dt(dt_or_str)
    else:
        dt = dt_or_str
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return max(0, (now - dt).days)


async def fetch_table_rows(coral: CoralClient, sql_query: str, table_name: str) -> list:
    print(f"Fetching {table_name}...")
    try:
        res = await coral.call_tool("sql", {"sql": sql_query})
        rows = json.loads(res).get("rows", [])
        print(f"  Fetched {len(rows)} {table_name}.")
        return rows
    except Exception as e:
        logger.error(f"Error fetching {table_name}: {e}", exc_info=True)
        return []


async def run_agent_loop(
    github_username: str, user_name: str, owner: str, repo: str,
    linear_display_name: str | None = None,
) -> DriftReport:
    print("Starting Drift Direct Query Pipeline...")

    async with CoralClient() as coral:
        pulls_sql = f"SELECT number, title, user__login, state, html_url, requested_reviewer_logins, created_at, updated_at, review_comments, body FROM github.pulls WHERE owner = '{owner}' AND repo = '{repo}'"
        pulls = await fetch_table_rows(coral, pulls_sql, "pulls from github")

        linear_user = linear_display_name or user_name
        issues_sql = f"SELECT identifier, title, state_name, assignee_name, updated_at, description FROM linear.issues WHERE assignee_name = '{linear_user}'"
        issues = await fetch_table_rows(coral, issues_sql, "issues from linear")

        slack = []

        now = datetime.now(timezone.utc)

        review_rows = []
        for p in pulls:
            if p.get("state") != "open":
                continue
            reviewers = p.get("requested_reviewer_logins") or ""
            if github_username not in reviewers:
                continue

            days_waiting = calculate_days_ago(p["created_at"], now)

            pr_num = p["number"]
            pr_url = p["html_url"]
            slack_mentions = sum(
                1
                for m in slack
                if f"PR #{pr_num}" in m.get("text", "") or pr_url in m.get("text", "")
            )

            blocks = None
            for iss in issues:
                desc = iss.get("description") or ""
                title = iss.get("title") or ""
                if pr_url in desc or pr_url in title:
                    blocks = iss["identifier"]
                    break

            review_rows.append(
                {
                    "pr_number": pr_num,
                    "title": p["title"],
                    "author": p["user__login"],
                    "repo": f"{owner}/{repo}",
                    "days_waiting": days_waiting,
                    "slack_mentions": slack_mentions,
                    "blocks": blocks,
                    "url": pr_url,
                }
            )

        reply_rows = []
        for m in slack:
            if m.get("thread_ts") is not None:
                continue
            if m.get("user") == github_username:
                continue

            has_reply = any(
                r.get("thread_ts") == m["ts"] and r.get("user") == github_username
                for r in slack
            )
            if has_reply:
                continue

            ts_val = float(m["ts"])
            msg_dt = datetime.fromtimestamp(ts_val, timezone.utc)
            days_ago = calculate_days_ago(msg_dt, now)

            reply_rows.append(
                {
                    "source": "slack",
                    "channel": m["channel"],
                    "from": m["user"],
                    "days_ago": days_ago,
                    "preview": m["text"],
                }
            )

        commitment_rows = []
        for iss in issues:
            if iss.get("state_name") not in ("In Progress", "Todo", "Blocked"):
                continue
            days_stale = calculate_days_ago(iss["updated_at"], now)

            commitment_rows.append(
                {
                    "task_id": iss["identifier"],
                    "title": iss["title"],
                    "status": iss["state_name"],
                    "days_stale": days_stale,
                    "last_commit_date": None,
                }
            )

        staleness_rows = []
        for p in pulls:
            if p.get("state") != "open":
                continue
            if p.get("user__login") != github_username:
                continue
            days_stale = calculate_days_ago(p["updated_at"], now)

            staleness_rows.append(
                {
                    "pr_number": p["number"],
                    "title": p["title"],
                    "repo": f"{owner}/{repo}",
                    "days_stale": days_stale,
                    "reviews": p.get("review_comments") or 0,
                    "url": p["html_url"],
                }
            )

        drift_rows = []
        for iss in issues:
            if iss.get("state_name") not in ("Done", "Completed", "Closed"):
                continue
            for p in pulls:
                if p.get("state") == "merged" or p.get("merged") is True:
                    continue
                issue_key = iss["identifier"]
                title = p.get("title") or ""
                body = p.get("body") or ""
                if issue_key in title or issue_key in body:
                    drift_rows.append(
                        {
                            "task_id": issue_key,
                            "task_title": iss["title"],
                            "task_status": iss["state_name"],
                            "pr_number": p["number"],
                            "pr_status": p["state"],
                            "contradiction": f"Task marked {iss['state_name']} in Linear but PR #{p['number']} is still {p['state']}",
                        }
                    )

        history_path = Path(__file__).parent.parent / "data" / "score_history.jsonl"

        print("Assembling structured DriftReport...")
        report = build_drift_report(
            user=user_name,
            review_rows=review_rows,
            reply_rows=reply_rows,
            commitment_rows=commitment_rows,
            staleness_rows=staleness_rows,
            drift_rows=drift_rows,
            history_path=history_path,
            write_history=True,
        )

        print("Generating AI Insight via single LLM call...")
        insight, suggested_plan = await generate_insight(report)

        report = report.model_copy(
            update={"insight": insight, "suggested_plan": suggested_plan}
        )

        print("Report generation complete.")
        return report
