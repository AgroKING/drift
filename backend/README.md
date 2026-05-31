# Drift Backend

The Drift backend is a Python package responsible for fetching raw data from developer tool APIs, calculating attention debt metrics, and generating AI insights.

---

## Package Structure

The backend code is divided into two packages:

### 1. `drift_logic/` (Core Logic)
Houses the database-agnostic domain logic. It has zero network dependencies:
- [models.py](file:///home/agp/PycharmProjects/drift/backend/drift_logic/models.py): Declares Pydantic validation models (`ReviewDebt`, `ReplyDebt`, `DriftReport`, etc.) and defines default values and validators (e.g., converting null URLs to empty strings).
- [scoring.py](file:///home/agp/PycharmProjects/drift/backend/drift_logic/scoring.py): Computes the personal attention debt score (clamped between 0 and 100) and selects the highest-priority "Top Action" item based on category weights.
- [history.py](file:///home/agp/PycharmProjects/drift/backend/drift_logic/history.py): Appends scores to a local JSONL file (`score_history.jsonl`) to compute score deltas over time.
- [report.py](file:///home/agp/PycharmProjects/drift/backend/drift_logic/report.py): Core builder that orchestrates row instantiation, scoring, top action selection, and history tracking.

### 2. `drift_agent/` (Agent Pipeline & Orchestration)
Handles all external interactions, CLI processing, and API connections:
- [main.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/main.py): Entrypoint for CLI parsing. Configures arguments for username, repository targets, mock vs live modes, and output paths.
- [agent_loop.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/agent_loop.py): Connects to the Coral Client, queries flat tables (`github.pulls`, `linear.issues`), parses and joins row data in Python, and returns a compiled `DriftReport` object.
- [insight_generator.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/insight_generator.py): Extracts report context, formats the LLM prompt, and requests exactly one JSON completion from the LLM containing the narrative and prioritized Suggested Plan list.
- [llm_client.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/llm_client.py): Handles standard OpenAI/Mistral streaming connections, rotates fallback models on connectivity or parser errors, processes `Retry-After` headers on 429 errors, and implements random jitter.
- [coral_client.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/coral_client.py): Implements standard JSON-RPC communication with the Coral MCP server stdio process.

---

## Developer Commands

Run all commands from the `backend/` directory:

### Run Linter Checks
```bash
uv run --with ruff ruff check .
```

### Format Code
```bash
uv run --with ruff ruff format .
```

### Run Test Suite
```bash
uv run --with pytest --with pytest-asyncio pytest tests/
```

### Run a Mock Scan
```bash
uv run drift_agent scan --mock --output data/drift_report.json
```

### Run a Live Scan (Requires Coral MCP Running)
```bash
uv run drift_agent scan --live --output data/drift_report.json
```