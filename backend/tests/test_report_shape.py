"""Tests for the DriftReport shape and serialisation contract."""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from drift_logic.models import (
    CommitmentDebt,
    DriftDebt,
    ReplyDebt,
    ReviewDebt,
    StalenessDebt,
)
from drift_logic.report import build_drift_report


def test_report_shape_matches_frontend_contract():
    """The to_dict() output must contain exactly the keys the frontend expects."""
    report = build_drift_report(
        user="agp",
        generated_at="2026-05-25T10:15:00Z",
        review_rows=[
            {
                "pr_number": 482,
                "title": "Add rate limiting to auth service",
                "author": "amit",
                "repo": "acme/backend",
                "days_waiting": 6,
                "slack_mentions": 3,
                "blocks": "LIN-891",
                "url": "https://github.com/acme/backend/pull/482",
            }
        ],
        reply_rows=[
            {
                "source": "slack",
                "channel": "#backend",
                "from": "amit",
                "days_ago": 1,
                "preview": "Any update?",
            }
        ],
    )

    payload = report.to_dict()

    assert payload["generated_at"] == "2026-05-25T10:15:00Z"
    assert payload["user"] == "agp"
    assert isinstance(payload["score"], int)
    assert isinstance(payload["score_delta"], int)
    assert set(payload["top_action"]) == {"text", "type", "url"}
    assert set(payload["debts"]) == {"review", "reply", "commitment", "staleness", "drift"}


def test_reply_debt_serialises_sender_as_from():
    """The frontend expects the key ``from``, not ``from_user``."""
    report = build_drift_report(
        user="agp",
        generated_at="2026-05-25T10:15:00Z",
        reply_rows=[
            {
                "source": "slack",
                "channel": "#backend",
                "from": "amit",
                "days_ago": 1,
                "preview": "Any update?",
            }
        ],
    )

    payload = report.to_dict()
    assert payload["debts"]["reply"][0]["from"] == "amit"
    assert "from_user" not in payload["debts"]["reply"][0]


def test_empty_report_has_no_action_and_zero_score():
    """An empty report should score 0 and have top_action.type 'none'."""
    payload = build_drift_report(
        user="agp", generated_at="2026-05-25T10:15:00Z"
    ).to_dict()

    assert payload["score"] == 0
    assert payload["top_action"]["type"] == "none"
    assert payload["debts"]["review"] == []


def test_invalid_rows_fail_pydantic_validation():
    """Rows with missing required fields or negative numbers must raise."""
    # Missing required 'title'
    with pytest.raises(Exception):
        ReviewDebt.from_row(
            {"pr_number": 1, "title": "", "author": "a", "repo": "r", "days_waiting": 1}
        )

    # Negative days_waiting
    with pytest.raises(Exception):
        ReviewDebt.from_row(
            {
                "pr_number": 1,
                "title": "ok",
                "author": "a",
                "repo": "r",
                "days_waiting": -5,
            }
        )


@pytest.mark.parametrize(
    ("model", "row"),
    [
        (
            ReviewDebt,
            {
                "title": "ok",
                "author": "a",
                "repo": "r",
                "days_waiting": 1,
                "slack_mentions": 0,
                "blocks": None,
                "url": None,
            },
        ),
        (
            ReplyDebt,
            {
                "source": "slack",
                "channel": "#backend",
                "days_ago": 1,
                "preview": "Any update?",
            },
        ),
        (
            CommitmentDebt,
            {
                "task_id": "LIN-1",
                "title": "ok",
                "status": "In Progress",
                "last_commit_date": None,
            },
        ),
        (
            StalenessDebt,
            {
                "pr_number": 1,
                "title": "ok",
                "repo": "r",
                "reviews": 0,
                "url": None,
            },
        ),
        (
            DriftDebt,
            {
                "task_id": "LIN-1",
                "task_title": "ok",
                "task_status": "Done",
                "pr_number": 1,
                "pr_status": "open",
            },
        ),
    ],
)
def test_missing_required_row_fields_fail(model, row):
    """Required query fields should not be silently defaulted."""
    with pytest.raises(KeyError):
        model.from_row(row)
