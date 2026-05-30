import json
import logging
import re
from pathlib import Path
from typing import Any, Dict, Union
from pydantic import ValidationError

from drift_logic.models import DriftReport

logger = logging.getLogger(__name__)


def extract_json_object(raw_json_str: str) -> str:
    """Extract the first valid JSON object from a raw string response."""
    cleaned = raw_json_str.strip()
    if cleaned.startswith("```json"):
        cleaned = cleaned[7:]
    elif cleaned.startswith("```"):
        cleaned = cleaned[3:]
    if cleaned.endswith("```"):
        cleaned = cleaned[:-3]
    cleaned = cleaned.strip()

    try:
        json.loads(cleaned)
        return cleaned
    except json.JSONDecodeError:
        pass

    start = cleaned.find("{")
    if start == -1:
        return cleaned

    depth = 0
    in_string = False
    escape = False
    for index, char in enumerate(cleaned[start:], start=start):
        if in_string:
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == '"':
                in_string = False
            continue

        if char == '"':
            in_string = True
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return cleaned[start : index + 1]

    return cleaned


def load_llm_json(raw_json_str: str) -> Dict[str, Any]:
    """Parse LLM JSON, repairing only common object-key quoting drift."""
    cleaned_json = extract_json_object(raw_json_str)
    try:
        data = json.loads(cleaned_json)
    except json.JSONDecodeError:
        repaired = re.sub(
            r"([{\[,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:",
            r'\1"\2":',
            cleaned_json,
        )
        data = json.loads(repaired)

    if not isinstance(data, dict):
        raise ValueError("Report JSON must be an object.")
    return data


def validate_and_write_report(
    raw_report: Union[DriftReport, str], output_path: str
) -> bool:
    try:
        if isinstance(raw_report, str):
            data = load_llm_json(raw_report)
            report_model = DriftReport(**data)
        else:
            report_model = raw_report

        out_json = report_model.model_dump_json(by_alias=True, indent=2)

        path = Path(output_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(out_json, encoding="utf-8")

        print(f"Drift report successfully written to {output_path}")
        return True
    except (json.JSONDecodeError, ValidationError, ValueError) as e:
        logger.error(f"Validation failed for LLM report: {e}")
        print(f"Validation Error: {e}")
        return False
