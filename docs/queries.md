# Drift Database Queries and Pipeline

This document explains how Drift fetches data from developer tools (GitHub, Linear, and Slack) using the Coral MCP SQL interface, and how those queries are integrated into our reporting pipeline.

## The Query Pipeline

Rather than executing complex multi-source SQL joins on the query engine (which can fail due to planner limitations like unsupported scalar subqueries or date casts), Drift uses a direct query-and-process architecture:

1. **Direct Queries:** We fetch raw flat tables for open pull requests, assigned issues, and messages.
2. **Python Joins & Processing:** The logic layer joins, counts, and filters the rows entirely in Python. This ensures database dialect compatibility and keeps exactly a single LLM invocation per scan.

All queries are executed dynamically inside [agent_loop.py](file:///home/agp/PycharmProjects/drift/backend/drift_agent/agent_loop.py).

---

## 1. GitHub Pull Requests

We query open and recently updated pull requests in the repository:

```sql
SELECT 
  number, 
  title, 
  user__login, 
  state, 
  html_url, 
  requested_reviewer_logins, 
  created_at, 
  updated_at, 
  review_comments, 
  body 
FROM github.pulls 
WHERE owner = '{owner}' 
  AND repo = '{repo}';
```

- **Review Debt:** Filtered in Python where `state == 'open'` and the developer's username is in `requested_reviewer_logins`.
- **Staleness Debt:** Filtered in Python where `state == 'open'` and `user__login == '{github_username}'`.

---

## 2. Linear Issues

We fetch all issues assigned to the developer that are currently active or recently closed:

```sql
SELECT 
  identifier, 
  title, 
  state_name, 
  assignee_name, 
  updated_at, 
  description 
FROM linear_mock.issues 
WHERE assignee_name = '{github_username}';
```

- **Commitment Debt:** Active tasks where `state_name` is in `('In Progress', 'Todo', 'Blocked')`.
- **Drift Debt:** Discrepancies where an issue status is closed (e.g. `Done`, `Completed`) but the linked pull request in GitHub is still open.

---

## 3. Slack Messages

We query Slack messages to detect threads or channel discussions that mention open PRs or need replies:

```sql
SELECT 
  channel, 
  text, 
  user, 
  ts, 
  thread_ts 
FROM slack_messages.messages;
```

- **Slack Mentions:** Checked by matching PR numbers or HTML URLs inside message texts.
- **Reply Debt:** Filtered in Python to find messages that don't have thread replies from the developer.
