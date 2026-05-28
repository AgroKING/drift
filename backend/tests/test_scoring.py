"""Tests for scoring weights and top-action selection."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from drift_logic.models import DebtBuckets, DriftDebt, ReviewDebt
from drift_logic.scoring import calculate_score, choose_top_action, score_review


def test_review_score_counts_age_mentions_and_blocker():
    """days_waiting * 3 + slack_mentions * 2 + 8 (blocker) => capped at 30."""
    item = ReviewDebt(
        pr_number=482,
        title="Add rate limiting",
        author="amit",
        repo="acme/backend",
        days_waiting=6,
        slack_mentions=3,
        blocks="LIN-891",
        url="https://example.com/pr/482",
    )

    # 6*3 + 3*2 + 8 = 18 + 6 + 8 = 32 → capped to 30
    assert score_review(item) == 30


def test_total_score_is_clamped_to_100():
    """10 heavy review items should exceed 100 but clamp to it."""
    debts = DebtBuckets(
        review=[
            ReviewDebt(
                pr_number=i,
                title=f"PR {i}",
                author="amit",
                repo="acme/backend",
                days_waiting=30,
                slack_mentions=10,
                blocks="LIN-1",
            )
            for i in range(10)
        ]
    )

    assert calculate_score(debts) == 100


def test_top_action_prefers_blocking_review():
    """A blocking review should win over drift / reply / staleness items."""
    debts = DebtBuckets(
        review=[
            ReviewDebt(
                pr_number=482,
                title="Add rate limiting",
                author="amit",
                repo="acme/backend",
                days_waiting=6,
                slack_mentions=3,
                blocks="LIN-891",
                url="https://example.com/pr/482",
            )
        ]
    )

    action = choose_top_action(debts)

    assert action.type == "review"
    assert "PR #482" in action.text


def test_drift_action_chosen_when_no_blocking_review():
    """With no review debt, a drift contradiction should become top action."""
    debts = DebtBuckets(
        drift=[
            DriftDebt(
                task_id="LIN-100",
                task_title="Implement auth",
                task_status="Done",
                pr_number=55,
                pr_status="open",
                contradiction="Task marked Done in Linear but PR #55 is open",
            )
        ]
    )

    action = choose_top_action(debts)

    assert action.type == "drift"
    assert "LIN-100" in action.text
