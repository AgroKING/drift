from unittest.mock import patch, AsyncMock

import pytest

from drift_agent.llm_client import convert_mcp_to_openai_tool
from drift_agent.report_writer import validate_and_write_report
from drift_agent.insight_generator import generate_insight
from drift_logic.models import DriftReport
from drift_logic.report import build_drift_report


def test_convert_mcp_to_openai_tool():
    mcp_tool = {
        "name": "sql",
        "description": "Execute a SQL query",
        "inputSchema": {
            "type": "object",
            "properties": {
                "sql": {"type": "string", "description": "SQL query to execute"}
            },
            "required": ["sql"],
        },
    }

    openai_tool = convert_mcp_to_openai_tool(mcp_tool)

    assert openai_tool["type"] == "function"
    assert openai_tool["function"]["name"] == "sql"
    assert openai_tool["function"]["description"] == "Execute a SQL query"
    assert (
        openai_tool["function"]["parameters"]["properties"]["sql"]["type"] == "string"
    )


def test_pydantic_native_cleanups():
    data = {
        "generated_at": "2026-05-25T10:15:00Z",
        "user": "agp",
        "score": 10,
        "score_delta": 2,
        "top_action": {"text": "Fix contradiction", "type": "drift", "url": None},
        "debts": {
            "review": [
                {
                    "pr_number": 482,
                    "title": "Add rate limiting",
                    "author": "amit",
                    "repo": "acme/backend",
                    "days_waiting": 6,
                    "slack_mentions": 3,
                    "blocks": "LIN-891",
                    "url": None,
                }
            ],
            "reply": [
                {
                    "source": "slack",
                    "channel": "#design-review",
                    "from": "sarah",
                    "days_ago": 3,
                    "preview": "API schema",
                }
            ],
            "commitment": [
                {
                    "task_id": "LIN-1",
                    "title": "ok",
                    "status": "In Progress",
                    "days_stale": 5,
                    "last_commit_date": None,
                }
            ],
            "staleness": [],
            "drift": [],
        },
    }

    report = DriftReport(**data)
    assert report.top_action.url == ""
    assert report.debts.review[0].url == ""
    assert report.debts.reply[0].from_user == "sarah"
    assert report.debts.commitment[0].last_commit_date is not None

    payload = report.to_dict()
    assert payload["top_action"]["url"] == ""
    assert payload["debts"]["review"][0]["url"] == ""
    assert payload["debts"]["reply"][0]["from"] == "sarah"


def test_validate_and_write_report(tmp_path):
    report_file = tmp_path / "drift_report.json"

    valid_json = """
    {
      "generated_at": "2026-05-25T10:15:00Z",
      "user": "agp",
      "score": 47,
      "score_delta": 12,
      "top_action": {
        "text": "Review PR #482",
        "type": "review",
        "url": "https://github.com/acme/backend/pull/482"
      },
      "debts": {
        "review": [],
        "reply": [],
        "commitment": [],
        "staleness": [],
        "drift": []
      }
    }
    """

    assert validate_and_write_report(valid_json, str(report_file)) is True
    assert report_file.exists()

    report = DriftReport(
        generated_at="2026-05-25T10:15:00Z",
        user="agp",
        score=47,
        score_delta=12,
        top_action={
            "text": "Review PR #482",
            "type": "review",
            "url": "https://github.com/acme/backend/pull/482",
        },
        debts={},
    )
    assert validate_and_write_report(report, str(report_file)) is True

    invalid_json = "{ invalid }"
    assert validate_and_write_report(invalid_json, str(report_file)) is False


@pytest.mark.asyncio
async def test_generate_insight():
    report = build_drift_report(user="agp")
    mock_response = AsyncMock()
    mock_response.content = (
        '{"insight": "focused work needed", "suggested_plan": ["step 1", "step 2"]}'
    )

    with patch(
        "drift_agent.insight_generator.call_llm", return_value=mock_response
    ) as mock_call:
        insight, plan = await generate_insight(report)
        assert insight == "focused work needed"
        assert plan == ["step 1", "step 2"]
        mock_call.assert_called_once()
