# Drift Database Schema Reference

This reference outlines the tables and fields exposed by our Coral MCP query engine, highlighting the data structures we use for tracking developer attention debt and identifying technical considerations.

---

## Data Source Status

We query a mix of live database schemas and local mock tables:

- **GitHub:** Connected to live GitHub API columns.
- **Linear:** Mocked via the `linear_mock.issues` table (using local JSONL data).
- **Slack:** Mocked via the `slack_messages.messages` table (using local JSONL data).
- **Notion:** Mocked via the `notion_mock.pages` table.

---

## 1. GitHub Integration

We retrieve pull requests directly from the live `github.pulls` table.

### Key Fields Used:
- `number` (Int64) and `title` (Utf8): The PR number and title.
- `user__login` (Utf8): GitHub username of the PR author.
- `requested_reviewer_logins` (Utf8): Comma-separated list of reviewers assigned to review the PR.
- `created_at` / `updated_at` (Utf8): ISO 8601 timestamps used to calculate wait times and staleness.
- `review_comments` (Int64): Total count of comments on the PR.
- `html_url` (Utf8): Web URL of the PR.

### Implementation Considerations:
- **Naming Conventions:** Nested GitHub properties use a **double underscore** (e.g., `user__login`, `assignee__login`).
- **Data Types:** Date fields (`created_at`, `updated_at`) are returned as ISO 8601 strings rather than native database timestamps.
- **Collection Structures:** `requested_reviewer_logins` is a simple comma-separated string, not a SQL array.

---

## 2. Linear Integration

Linear active issues are queried from `linear_mock.issues`.

### Key Fields Used:
- `identifier` (Utf8): The issue ID (e.g., `ENG-01`).
- `title` (Utf8) and `description` (Utf8): The summary and body.
- `state_name` (Utf8): The current workflow status (e.g., `Todo`, `In Progress`, `Done`).
- `assignee_name` (Utf8): The developer's name.
- `updated_at` (Utf8): ISO 8601 string used to determine stale tasks.

### Implementation Considerations:
- **Naming Conventions:** Unlike GitHub, Linear nested properties use a **single underscore** (e.g., `state_name`, `assignee_name`). Avoid mixing up single and double underscore conventions across sources.

---

## 3. Slack Integration

Slack messages are loaded from `slack_messages.messages`.

### Key Fields Used:
- `channel` (Utf8): The channel name/ID.
- `text` (Utf8): Raw message content. We inspect this to see if a PR url or number is mentioned.
- `user` (Utf8): The sender's username.
- `ts` (Utf8): Unix timestamp string.
- `thread_ts` (Utf8): Thread parent timestamp. Used to filter out message replies and match threads.

---

## 4. Notion Integration

Notion pages are loaded from `notion_mock.pages`.

### Key Fields Used:
- `id` (Utf8): The page ID.
- `last_edited_time` (Utf8): Last edit ISO string.
- `url` (Utf8): Notion page URL.
- `properties` (Utf8): A serialized JSON string containing all custom page fields.

### Implementation Considerations:
- **Serialized JSON Blobs:** Page titles and custom fields are packed inside `properties` as a serialized JSON string. These fields cannot be directly filtered using standard SQL column queries.
