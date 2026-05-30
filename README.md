# Drift: Developer Attention Debt Tracker

Drift is a personal dashboard designed to track and optimize a developer's "attention debt" across GitHub, Linear, Slack, and Notion. It consolidates notifications, review requests, unanswered messages, stale tasks, and tool state discrepancies into a single, clean, glassmorphic UI.

Rather than letting attention scatter across multiple tabs and notifications, Drift calculates a unified **Attention Debt Score** (from 0 to 100) and highlights the single most critical action to unblock the team.

---

## Project Architecture

The codebase is split into two primary components:

1. **Backend (Python):** Exposes a CLI and local server. It queries developer tool tables using the Coral MCP SQL interface, processes raw data, scores the debt categories, and generates a natural-language executive summary via the Mistral LLM.
2. **Frontend (Flutter Web):** A premium, glassmorphic web dashboard that displays the Attention Debt Score, the AI Insight card, and the categorized lists of debt items.

---

## How It Works: The Data & AI Pipeline

### 1. Direct Database Fetching (Python Processing)
Rather than executing complex database-side SQL joins—which often fail or hit limitations on federated query planners—Drift queries flat schemas directly:
- **GitHub:** `github.pulls` matches active pull requests in the target repository.
- **Linear:** `linear_mock.issues` retrieves issues assigned to the developer.
- **Slack:** `slack_messages.messages` retrieves workspace channel history.

Once the rows are fetched, the Python logic layer ([agent_loop.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/agent_loop.py)) processes the datasets:
- Maps GitHub PRs against Slack mentions and links them to blocking Linear issues.
- Scans Slack threads to find messages where the developer has not yet replied.
- Identifies state discrepancies (e.g., a task marked "Done" in Linear, but its linked GitHub PR is still open).

### 2. Attention Debt Scoring
Drift calculates a deterministic score from `0` (clean) to `100` (overloaded) based on five categories:
- **Review Debt (max 30 pts/item):** Waiting time, Slack pings, and blocker status.
- **Reply Debt (max 20 pts/item):** Time elapsed since a Slack/Notion message went unanswered.
- **Commitment Debt (max 20 pts/item):** Number of days assigned tasks have sat in progress without commits.
- **Staleness Debt (max 15 pts/item):** Developer's own open PRs that have stalled without reviews.
- **Drift Debt (12 or 15 pts/item):** Inconsistencies between Linear task status and GitHub PR state.

### 3. Single-Call AI Insight Generation
To remain efficient, Drift makes exactly **one** LLM request per scan. 
- The structured report is formatted into a concise text prompt.
- The assistant ([insight_generator.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/insight_generator.py)) asks the LLM to output a raw JSON object containing an executive summary (`insight`) and a prioritized list of up to 4 action items (`suggested_plan`).
- **Resilience & Fallbacks:** The LLM client ([llm_client.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/llm_client.py)) includes rotating model preferences, rate-limit retry headers handling, and silent fallback default values if the LLM is completely unavailable.

---

## Getting Started

### Backend Setup

1. **Configure Environment:**
   Create a `backend/.env` file with your details:
   ```env
   MISTRAL_API_KEY=your_api_key
   MISTRAL_BASE_URL=https://api.mistral.ai/v1
   MISTRAL_MODEL=mistral-large-latest
   DRIFT_GITHUB_USERNAME=your_username
   DRIFT_USER_NAME=your_display_name
   GITHUB_OWNER=repo_owner
   GITHUB_REPO=repo_name
   ```

2. **Run a Scan:**
   You can run a scan in mock mode (using packaged developer rows) or live mode:
   ```bash
   cd backend
   # Mock mode
   uv run drift_agent scan --mock
   
   # Live mode (requires active Coral MCP server)
   uv run drift_agent scan --live
   ```
   This generates a JSON report at `backend/data/drift_report.json`.

3. **Start the Report Server:**
   Start a simple HTTP server on port 8080 to serve the report to the frontend:
   ```bash
   cd backend/data
   python3 -m http.server 8080
   ```

### Frontend Setup

Drift's frontend is a high-performance, web-native dashboard (pure HTML5 + Tailwind CSS + Vanilla JS) served directly from `frontend/web/`. There is no compilation or build overhead.

1. **Run the Frontend Server:**
   Start the local frontend server:
   ```bash
   ./scripts/run_frontend.sh
   ```
   This hosts the dashboard at `http://localhost:8081`.

2. **Toggle Modes:**
   - **MOCK Mode (Default):** Loads static, structured data from `assets/mock_drift_report.json`.
   - **LIVE Mode:** Make sure you are running the backend scan and the CORS server via `./scripts/serve_report.sh`. Then, toggle the button in the top-right navbar to **LIVE** to fetch and render real-time attention debt data.
