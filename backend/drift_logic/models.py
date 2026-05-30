"""Drift report Pydantic v2 schemas and validation models."""

from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, List, Literal, Mapping, Optional

from pydantic import BaseModel, Field, field_validator

# Helpers

ACTION_TYPES = Literal["review", "reply", "commitment", "staleness", "drift", "none"]


def utc_now_iso() -> str:
    """Return a frontend-friendly UTC timestamp."""
    return (
        datetime.now(timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )


# Debt items


class TopAction(BaseModel):
    """The single most-urgent action surfaced at the top of the report."""

    text: str = Field(..., min_length=1)
    type: ACTION_TYPES
    url: str = ""

    @classmethod
    def none(cls) -> "TopAction":
        return cls(text="No urgent drift action right now.", type="none", url="")

    @field_validator("url", mode="before")
    @classmethod
    def empty_string_for_none(cls, v: Any) -> str:
        return "" if v is None else v


class ReviewDebt(BaseModel):
    """Someone is waiting for the current user to review a PR."""

    pr_number: int = Field(..., ge=0)
    title: str = Field(..., min_length=1)
    author: str = Field(..., min_length=1)
    repo: str = Field(..., min_length=1)
    days_waiting: int = Field(..., ge=0)
    slack_mentions: int = Field(default=0, ge=0)
    blocks: Optional[str] = None
    url: str = ""

    @classmethod
    def from_row(cls, row: Mapping[str, Any]) -> "ReviewDebt":
        return cls(
            pr_number=row["pr_number"],
            title=row["title"],
            author=row["author"],
            repo=row["repo"],
            days_waiting=row["days_waiting"],
            slack_mentions=row.get("slack_mentions", 0),
            blocks=row.get("blocks"),
            url=row.get("url") or "",
        )

    @field_validator("url", mode="before")
    @classmethod
    def empty_string_for_none(cls, v: Any) -> str:
        return "" if v is None else v


class ReplyDebt(BaseModel):
    """The current user owes someone a response."""

    source: str = Field(..., min_length=1)
    channel: str = Field(..., min_length=1)
    from_user: str = Field(..., min_length=1, alias="from")
    days_ago: int = Field(..., ge=0)
    preview: str = Field(..., min_length=1)

    model_config = {"populate_by_name": True}

    @classmethod
    def from_row(cls, row: Mapping[str, Any]) -> "ReplyDebt":
        sender = row["from"] if "from" in row else row["from_user"]
        return cls(
            source=row["source"],
            channel=row["channel"],
            **{"from": sender},
            days_ago=row["days_ago"],
            preview=row["preview"],
        )

    def model_dump(self, **kwargs: Any) -> dict[str, Any]:
        """Ensure the serialised key is ``from``, not ``from_user``."""
        kwargs.setdefault("by_alias", True)
        return super().model_dump(**kwargs)


class CommitmentDebt(BaseModel):
    """The current user owns a task that has gone stale."""

    task_id: str = Field(..., min_length=1)
    title: str = Field(..., min_length=1)
    status: str = Field(..., min_length=1)
    days_stale: int = Field(..., ge=0)
    last_commit_date: str = Field(default_factory=utc_now_iso)

    @classmethod
    def from_row(cls, row: Mapping[str, Any]) -> "CommitmentDebt":
        return cls(
            task_id=row["task_id"],
            title=row["title"],
            status=row["status"],
            days_stale=row["days_stale"],
            last_commit_date=row.get("last_commit_date") or utc_now_iso(),
        )

    @field_validator("last_commit_date", mode="before")
    @classmethod
    def check_last_commit_date(cls, v: Any) -> str:
        return utc_now_iso() if v is None else v


class StalenessDebt(BaseModel):
    """The current user's own PR has stopped moving."""

    pr_number: int = Field(..., ge=0)
    title: str = Field(..., min_length=1)
    repo: str = Field(..., min_length=1)
    days_stale: int = Field(..., ge=0)
    reviews: int = Field(default=0, ge=0)
    url: str = ""

    @classmethod
    def from_row(cls, row: Mapping[str, Any]) -> "StalenessDebt":
        return cls(
            pr_number=row["pr_number"],
            title=row["title"],
            repo=row["repo"],
            days_stale=row["days_stale"],
            reviews=row.get("reviews", 0),
            url=row.get("url") or "",
        )

    @field_validator("url", mode="before")
    @classmethod
    def empty_string_for_none(cls, v: Any) -> str:
        return "" if v is None else v


class DriftDebt(BaseModel):
    """Linear and GitHub disagree about state."""

    task_id: str = Field(..., min_length=1)
    task_title: str = Field(..., min_length=1)
    task_status: str = Field(..., min_length=1)
    pr_number: int = Field(..., ge=0)
    pr_status: str = Field(..., min_length=1)
    contradiction: str = Field(..., min_length=1)

    @classmethod
    def from_row(cls, row: Mapping[str, Any]) -> "DriftDebt":
        return cls(
            task_id=row["task_id"],
            task_title=row["task_title"],
            task_status=row["task_status"],
            pr_number=row["pr_number"],
            pr_status=row["pr_status"],
            contradiction=row["contradiction"],
        )


# Aggregates


class DebtBuckets(BaseModel):
    """Container for all five debt categories."""

    review: List[ReviewDebt] = Field(default_factory=list)
    reply: List[ReplyDebt] = Field(default_factory=list)
    commitment: List[CommitmentDebt] = Field(default_factory=list)
    staleness: List[StalenessDebt] = Field(default_factory=list)
    drift: List[DriftDebt] = Field(default_factory=list)

    def to_dict(self) -> dict[str, list[dict[str, Any]]]:
        return {
            "review": [item.model_dump() for item in self.review],
            "reply": [item.model_dump() for item in self.reply],
            "commitment": [item.model_dump() for item in self.commitment],
            "staleness": [item.model_dump() for item in self.staleness],
            "drift": [item.model_dump() for item in self.drift],
        }


class DriftReport(BaseModel):
    """The full drift report consumed by the frontend."""

    generated_at: str = Field(..., min_length=1)
    user: str = Field(..., min_length=1)
    score: int = Field(..., ge=0, le=100)
    score_delta: int
    top_action: TopAction
    debts: DebtBuckets
    insight: Optional[str] = None
    suggested_plan: Optional[List[str]] = Field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "generated_at": self.generated_at,
            "user": self.user,
            "score": self.score,
            "score_delta": self.score_delta,
            "top_action": self.top_action.model_dump(),
            "debts": self.debts.to_dict(),
            "insight": self.insight,
            "suggested_plan": self.suggested_plan,
        }
