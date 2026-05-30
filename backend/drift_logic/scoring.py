"""Deterministic debt scoring weights and top-action selection logic."""

from __future__ import annotations

from .models import (
    CommitmentDebt,
    DebtBuckets,
    DriftDebt,
    ReplyDebt,
    ReviewDebt,
    StalenessDebt,
    TopAction,
)

MAX_SCORE = 100


def clamp(value: int, low: int = 0, high: int = MAX_SCORE) -> int:
    return max(low, min(high, value))


# Per-item scorers


def score_review(item: ReviewDebt) -> int:
    score = item.days_waiting * 3 + item.slack_mentions * 2
    if item.blocks:
        score += 8
    return min(score, 30)


def score_reply(item: ReplyDebt) -> int:
    return min(item.days_ago * 2, 20)


def score_commitment(item: CommitmentDebt) -> int:
    return min(item.days_stale * 2, 20)


def score_staleness(item: StalenessDebt) -> int:
    score = item.days_stale * 2
    if item.reviews == 0:
        score += 5
    return min(score, 15)


def score_drift(item: DriftDebt) -> int:
    closed_statuses = {"done", "completed", "closed"}
    if (
        item.task_status.lower() in closed_statuses
        and item.pr_status.lower() != "merged"
    ):
        return 15
    return 12


# Aggregate scorer


def calculate_score(debts: DebtBuckets) -> int:
    total = 0
    total += sum(score_review(item) for item in debts.review)
    total += sum(score_reply(item) for item in debts.reply)
    total += sum(score_commitment(item) for item in debts.commitment)
    total += sum(score_staleness(item) for item in debts.staleness)
    total += sum(score_drift(item) for item in debts.drift)
    return clamp(total)


# Top-action selector prioritised by: 1. Blocker review, 2. Drift, 3. Stale commitment, 4. Reply, 5. Stale PR.


def choose_top_action(debts: DebtBuckets) -> TopAction:
    candidates: list[tuple[int, TopAction]] = []

    # 1 — Blocking reviews get the highest boost
    for item in debts.review:
        priority = score_review(item) + (10 if item.blocks else 0)
        text = (
            f"Review PR #{item.pr_number}: {item.title} by @{item.author} "
            f"has waited {item.days_waiting} days."
        )
        if item.blocks:
            text += f" It is blocking {item.blocks}."
        candidates.append((priority, TopAction(text=text, type="review", url=item.url)))

    # 2 — Drift contradictions
    for item in debts.drift:
        priority = score_drift(item) + 20
        text = f"Resolve drift on {item.task_id}: {item.contradiction}"
        candidates.append((priority, TopAction(text=text, type="drift", url=None)))

    # 3 — Stale commitments
    for item in debts.commitment:
        priority = score_commitment(item)
        text = f"Update {item.task_id}: {item.title} has been stale for {item.days_stale} days."
        candidates.append((priority, TopAction(text=text, type="commitment", url=None)))

    # 4 — Unanswered replies
    for item in debts.reply:
        priority = score_reply(item)
        text = f"Reply to {item.from_user} in {item.channel}: {item.preview}"
        candidates.append((priority, TopAction(text=text, type="reply", url=None)))

    # 5 — Stale PRs
    for item in debts.staleness:
        priority = score_staleness(item)
        text = f"Move PR #{item.pr_number}: {item.title} has been stale for {item.days_stale} days."
        candidates.append(
            (priority, TopAction(text=text, type="staleness", url=item.url))
        )

    if not candidates:
        return TopAction.none()

    return max(candidates, key=lambda candidate: candidate[0])[1]
