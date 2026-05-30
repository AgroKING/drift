"""Track Attention Debt Score history inside a local JSONL file."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def read_score_history(path: str | Path) -> list[dict[str, Any]]:
    """Return every history entry from the JSONL file, or [] if it doesn't exist."""
    history_path = Path(path)
    if not history_path.exists():
        return []

    entries: list[dict[str, Any]] = []
    for line_number, line in enumerate(
        history_path.read_text(encoding="utf-8").splitlines(), start=1
    ):
        if not line.strip():
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError as exc:
            raise ValueError(f"Invalid JSONL at {history_path}:{line_number}") from exc
        entries.append(entry)
    return entries


def previous_score(path: str | Path, user: str) -> int | None:
    """Return the most recent score for *user*, or ``None``."""
    for entry in reversed(read_score_history(path)):
        if entry.get("user") == user and "score" in entry:
            return int(entry["score"])
    return None


def calculate_score_delta(path: str | Path, user: str, current_score: int) -> int:
    """Delta = current_score − latest stored score.  0 when no history."""
    last_score = previous_score(path, user)
    if last_score is None:
        return 0
    return current_score - last_score


def append_score(path: str | Path, *, generated_at: str, user: str, score: int) -> None:
    """Append a single history row to the JSONL file (creates parents if needed)."""
    history_path = Path(path)
    history_path.parent.mkdir(parents=True, exist_ok=True)
    payload = {"generated_at": generated_at, "user": user, "score": score}
    with history_path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, sort_keys=True) + "\n")
