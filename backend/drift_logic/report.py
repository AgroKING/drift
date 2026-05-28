"""Build the final Drift report consumed by the frontend.

Person 3 calls ``build_drift_report(user=..., review_rows=[...], ...)`` with
raw row dicts straight from Coral query results.  This module normalises them
into Pydantic models, scores them, and returns a ``DriftReport``.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any, Iterable, Mapping

from .history import append_score, calculate_score_delta
from .models import (
    CommitmentDebt,
    DebtBuckets,
    DriftDebt,
    DriftReport,
    ReplyDebt,
    ReviewDebt,
    StalenessDebt,
    utc_now_iso,
)
from .scoring import calculate_score, choose_top_action


def _rows(rows: Iterable[Mapping[str, Any]] | None) -> list[Mapping[str, Any]]:
    """Coerce *rows* to a concrete list; ``None`` becomes ``[]``."""
    return list(rows or [])


def build_debt_buckets(
    *,
    review_rows: Iterable[Mapping[str, Any]] | None = None,
    reply_rows: Iterable[Mapping[str, Any]] | None = None,
    commitment_rows: Iterable[Mapping[str, Any]] | None = None,
    staleness_rows: Iterable[Mapping[str, Any]] | None = None,
    drift_rows: Iterable[Mapping[str, Any]] | None = None,
) -> DebtBuckets:
    """Parse raw row dicts into validated Pydantic debt models."""
    return DebtBuckets(
        review=[ReviewDebt.from_row(row) for row in _rows(review_rows)],
        reply=[ReplyDebt.from_row(row) for row in _rows(reply_rows)],
        commitment=[CommitmentDebt.from_row(row) for row in _rows(commitment_rows)],
        staleness=[StalenessDebt.from_row(row) for row in _rows(staleness_rows)],
        drift=[DriftDebt.from_row(row) for row in _rows(drift_rows)],
    )


def build_drift_report(
    *,
    user: str,
    review_rows: Iterable[Mapping[str, Any]] | None = None,
    reply_rows: Iterable[Mapping[str, Any]] | None = None,
    commitment_rows: Iterable[Mapping[str, Any]] | None = None,
    staleness_rows: Iterable[Mapping[str, Any]] | None = None,
    drift_rows: Iterable[Mapping[str, Any]] | None = None,
    generated_at: str | None = None,
    history_path: str | Path | None = None,
    write_history: bool = False,
) -> DriftReport:
    """End-to-end report builder.

    Accepts the raw row lists that Person 3 fetches from Coral, normalises
    them into Pydantic models, calculates a score, picks a top action, and
    optionally persists score history.
    """
    if not user.strip():
        raise ValueError("user is required")

    debts = build_debt_buckets(
        review_rows=review_rows,
        reply_rows=reply_rows,
        commitment_rows=commitment_rows,
        staleness_rows=staleness_rows,
        drift_rows=drift_rows,
    )
    score = calculate_score(debts)
    timestamp = generated_at or utc_now_iso()

    score_delta = (
        calculate_score_delta(history_path, user, score) if history_path else 0
    )

    report = DriftReport(
        generated_at=timestamp,
        user=user,
        score=score,
        score_delta=score_delta,
        top_action=choose_top_action(debts),
        debts=debts,
    )

    if write_history and history_path:
        append_score(history_path, generated_at=timestamp, user=user, score=score)

    return report
