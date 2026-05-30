"""Tests for JSONL score history."""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from drift_logic.history import (
    append_score,
    calculate_score_delta,
    previous_score,
    read_score_history,
)


def test_history_round_trip(tmp_path):
    """Append two entries and read them back."""
    path = tmp_path / "score_history.jsonl"

    append_score(path, generated_at="2026-05-24T10:00:00Z", user="agp", score=35)
    append_score(path, generated_at="2026-05-25T10:00:00Z", user="agp", score=47)

    history = read_score_history(path)

    assert len(history) == 2
    assert history[0]["score"] == 35
    assert history[1]["score"] == 47


def test_previous_score_returns_latest_for_user(tmp_path):
    """previous_score should return the *last* entry for the matching user."""
    path = tmp_path / "score_history.jsonl"

    append_score(path, generated_at="2026-05-24T10:00:00Z", user="agp", score=35)
    append_score(path, generated_at="2026-05-25T10:00:00Z", user="agp", score=47)

    assert previous_score(path, "agp") == 47


def test_score_delta_uses_latest_matching_user(tmp_path):
    """Delta should be current − latest score for the *same* user, ignoring others."""
    path = tmp_path / "score_history.jsonl"

    append_score(
        path, generated_at="2026-05-24T10:00:00Z", user="someone-else", score=99
    )
    append_score(path, generated_at="2026-05-24T10:00:00Z", user="agp", score=35)

    assert calculate_score_delta(path, "agp", 47) == 12


def test_missing_history_returns_empty_list_and_zero_delta(tmp_path):
    """Non-existent file → empty list, delta 0."""
    path = tmp_path / "missing.jsonl"

    assert read_score_history(path) == []
    assert calculate_score_delta(path, "agp", 47) == 0
