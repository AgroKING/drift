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
- **GitHub:** `github.pulls` retrieves active pull requests from the target repository (live API).
- **Linear:** `linear.issues` retrieves issues assigned to the developer (live API).
- **Notion:** `notion.pages` retrieves workspace documents (live API, pending agent integration).
- **Slack:** Not configured.

Once the rows are fetched, the Python logic layer ([agent_loop.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/agent_loop.py)) processes the datasets:
- Maps GitHub PRs and links them to blocking Linear issues.
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

### 1. Configure Environment
Create a `backend/.env` file in the `backend/` directory:
```env
MISTRAL_API_KEY=your_api_key
LINEAR_API_KEY=your_linear_api_key
NOTION_API_KEY=your_notion_api_key

# Target Repository Details
GITHUB_OWNER=repo_owner
GITHUB_REPO=repo_name

# Developer Profiles
DRIFT_USER_NAME="Your Display Name"
DRIFT_GITHUB_USERNAME=your_github_username
DRIFT_LINEAR_NAME="Your Linear Display Name"
```

### 2. Configure Coral Sources
Ensure your native APIs are connected to Coral beforehand by running:
```bash
# Register Linear credentials
LINEAR_API_KEY="your_linear_api_key" coral source add linear

# Register Notion credentials
NOTION_API_KEY="your_notion_api_key" coral source add notion
```

### 3. Run Everything
We provide a unified orchestrator script that automatically performs the backend scan, starts the CORS report server (port 8080), and hosts the frontend dashboard (port 8081) in one command:
```bash
./start.sh
```

Once running, you can access:
* 🖥️ **Dashboard:** [http://localhost:8081](http://localhost:8081)
* 📡 **Live Report JSON:** [http://localhost:8080/drift_report.json](http://localhost:8080/drift_report.json)

Toggle the dashboard in the top-right corner to **LIVE MODE** to fetch and render the live attention debt data.

Press `Ctrl+C` in your terminal to cleanly stop all running servers.

