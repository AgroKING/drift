import json
import logging
from typing import Tuple, List, Optional
from drift_logic.models import DriftReport
from .llm_client import call_llm

logger = logging.getLogger(__name__)


def parse_json_response(content: str) -> dict:
    cleaned = content.strip().strip("`").strip()
    if cleaned.lower().startswith("json"):
        cleaned = cleaned[4:].strip()
    return json.loads(cleaned)


async def generate_insight(report: DriftReport) -> Tuple[Optional[str], List[str]]:
    review_desc = [
        f"PR #{d.pr_number} '{d.title}' by @{d.author} (waiting {d.days_waiting} days)"
        for d in report.debts.review
    ]
    reply_desc = [
        f"Message from @{d.from_user} on {d.source} {d.channel} ({d.days_ago} days ago): '{d.preview}'"
        for d in report.debts.reply
    ]
    commitment_desc = [
        f"Task {d.task_id} '{d.title}' status {d.status} (stale for {d.days_stale} days)"
        for d in report.debts.commitment
    ]
    staleness_desc = [
        f"My PR #{d.pr_number} '{d.title}' in {d.repo} (stale for {d.days_stale} days)"
        for d in report.debts.staleness
    ]
    drift_desc = [
        f"Linear Task {d.task_id} marked {d.task_status} but GitHub PR #{d.pr_number} is still {d.pr_status}"
        for d in report.debts.drift
    ]

    lines = [
        f"Developer: {report.user}",
        f"Overall Attention Debt Score: {report.score} (out of 100, where higher is worse)",
        f"Score Delta: {report.score_delta}",
        f"Top Action Priority: {report.top_action.text if report.top_action else 'None'}",
        "",
        "Unresolved Debts:",
    ]
    for desc, label in [
        (review_desc, "Review Debt (PRs waiting for my review)"),
        (reply_desc, "Reply Debt (Messages needing my reply)"),
        (commitment_desc, "Commitment Debt (My stale tasks)"),
        (staleness_desc, "Staleness Debt (My stale open PRs)"),
        (drift_desc, "Drift Debt (Linear-GitHub state mismatches)"),
    ]:
        lines.append(f"- {label}: {len(desc)} items")
        for x in desc[:3]:
            lines.append(f"  * {x}")

    summary = "\n".join(lines)

    system_prompt = (
        "You are the Drift AI Assistant. Your task is to analyze the developer's attention debt report "
        "and generate a short executive summary and a prioritized list of action steps.\n\n"
        "Instructions:\n"
        "1. Write a concise executive summary ('insight') of 1-3 sentences maximum. Highlight key themes, "
        "e.g. if they are blocking others on PR reviews, or if they have too many stale tasks/messages.\n"
        "2. Provide a list of up to 4 specific, concrete, prioritized actions ('suggested_plan') the developer "
        "should take. Be specific (e.g. referencing actual PR numbers, Slack channels, or developer names from the report).\n"
        "3. You must respond ONLY with a raw JSON object containing exactly these two keys:\n"
        '   - "insight": string\n'
        '   - "suggested_plan": list of strings\n'
        "Do NOT include any markdown code blocks, explanatory text, or preamble outside the JSON."
    )

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": f"Here is the attention debt report:\n\n{summary}"},
    ]

    try:
        logger.info("Requesting AI insight from LLM...")
        response = await call_llm(messages=messages, tools=None)
        if not response.content:
            logger.warning("LLM response content was empty.")
            return None, []

        parsed = parse_json_response(response.content)
        insight = parsed.get("insight")
        suggested_plan = parsed.get("suggested_plan", [])
        if not isinstance(suggested_plan, list):
            suggested_plan = []
        return insight, [str(item) for item in suggested_plan]
    except Exception as e:
        logger.error(f"Failed to generate AI insight: {e}", exc_info=True)
        return None, []
