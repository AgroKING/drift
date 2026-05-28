# Drift Schema Notes

> Generated from live `coral.columns` inspection.
> Owner: Person 1 — Source: real Coral query output.
> Last updated: 2025-05-28

---

## Source Status

| Source  | Status        | Notes                                              |
|:--------|:--------------|:---------------------------------------------------|
| GitHub  | ✅ Real data  | Connected, queries working                         |
| Linear  | ⚠️ Mock data  | Real API connected but no workspace data — using JSONL mock |
| Slack   | ⚠️ Mock data  | No `messages` table in Coral — using JSONL mock    |
| Notion  | ⚠️ Mock data  | Connected — using JSONL mock for demo              |

---

## GitHub

### github.pulls

**Required filters:** `owner`, `repo`  
**Optional filters:** `state` (`open` | `closed` | `all`)

**Key columns for Drift:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `number` | Int64 | PR number |
| `title` | Utf8 | PR title |
| `state` | Utf8 | `open` or `closed` |
| `draft` | Boolean | Is it a draft PR? |
| `created_at` | Utf8 | ISO 8601 string e.g. `2025-05-01T10:00:00Z` |
| `updated_at` | Utf8 | ISO 8601 string |
| `merged_at` | Utf8 | ISO 8601 string, null if not merged |
| `closed_at` | Utf8 | ISO 8601 string, null if open |
| `html_url` | Utf8 | Link to PR |
| `user__login` | Utf8 | PR author GitHub username |
| `user__name` | Utf8 | PR author display name |
| `assignee__login` | Utf8 | Assigned reviewer login |
| `requested_reviewer_logins` | Utf8 | Comma-separated reviewer logins |
| `review_comments` | Int64 | Number of review comments |
| `owner` | Utf8 | Repo owner (required filter) |
| `repo` | Utf8 | Repo name (required filter) |
| `head__ref` | Utf8 | Source branch name |
| `base__ref` | Utf8 | Target branch name |
| `merged` | Boolean | Whether PR was merged |
| `mergeable` | Boolean | Whether PR can be merged |

**Sample query:**
```sql
SELECT number, title, state, draft, user__login, created_at, updated_at, html_url
FROM github.pulls
WHERE owner = 'AgroKING'
  AND repo = 'drift'
  AND state = 'open'
ORDER BY updated_at ASC
LIMIT 20
```

**Gotchas:**
- `created_at` and `updated_at` are ISO strings, not native timestamps — use string comparison for filtering e.g. `updated_at < '2025-05-25T00:00:00Z'`
- `requested_reviewer_logins` may be a comma-separated string, not an array
- Draft PRs (`draft = true`) should likely be excluded from stale PR detection

---

### github.issues

**Required filters:** `owner`, `repo`  
**Optional filters:** `state` (`open` | `closed` | `all`), `org`

**Key columns for Drift:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `number` | Int64 | Issue number |
| `title` | Utf8 | Issue title |
| `state` | Utf8 | `open` or `closed` |
| `body` | Utf8 | Issue description |
| `created_at` | Utf8 | ISO 8601 string |
| `updated_at` | Utf8 | ISO 8601 string |
| `closed_at` | Utf8 | ISO 8601 string, null if open |
| `html_url` | Utf8 | Link to issue |
| `user__login` | Utf8 | Issue author |
| `assignee__login` | Utf8 | Assigned person login |
| `assignee__name` | Utf8 | Assigned person display name |
| `comments` | Int64 | Number of comments |
| `labels` | Utf8 | Serialized labels |
| `milestone__title` | Utf8 | Milestone name if set |
| `owner` | Utf8 | Repo owner (required filter) |
| `repo` | Utf8 | Repo name (required filter) |
| `pull_request` | Utf8 | Non-null if issue is actually a PR |

**Sample query:**
```sql
SELECT number, title, state, user__login, assignee__login, created_at, updated_at, html_url
FROM github.issues
WHERE owner = 'AgroKING'
  AND repo = 'drift'
  AND state = 'open'
ORDER BY updated_at ASC
LIMIT 20
```

**Gotchas:**
- GitHub's API returns PRs inside `github.issues` too — filter them out with `pull_request IS NULL` if you only want real issues
- `labels` is a serialized string, not a queryable array

---

### github.commits

**Required filters:** `owner`, `repo`  
**Optional filters:** `ref` (branch), `path`, `pull_number`

**Key columns for Drift:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `sha` | Utf8 | Commit SHA |
| `commit__message` | Utf8 | Commit message |
| `commit__author__name` | Utf8 | Author name |
| `commit__author__email` | Utf8 | Author email |
| `commit__author__date` | Utf8 | ISO 8601 string |
| `commit__committer__date` | Utf8 | Committer date |
| `author__login` | Utf8 | GitHub login of author |
| `stats__additions` | Int64 | Lines added |
| `stats__deletions` | Int64 | Lines deleted |
| `stats__total` | Int64 | Total lines changed |
| `html_url` | Utf8 | Link to commit |
| `owner` | Utf8 | Required filter |
| `repo` | Utf8 | Required filter |

**Sample query:**
```sql
SELECT sha, commit__message, commit__author__name, commit__author__date, html_url
FROM github.commits
WHERE owner = 'AgroKING'
  AND repo = 'drift'
ORDER BY commit__author__date DESC
LIMIT 20
```

---

## Linear

> ⚠️ Using JSONL mock at `linear_mock.messages` — real API connected but no workspace data.

### linear.issues

**Required filters:** none (but always filter by `assignee_name` or `state_name`)

**Key columns for Drift:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `id` | Utf8 | Internal UUID |
| `identifier` | Utf8 | Human ID e.g. `ENG-01` |
| `title` | Utf8 | Issue title |
| `description` | Utf8 | Issue body |
| `state_name` | Utf8 | e.g. `In Progress`, `Todo`, `Done` — NOTE: single underscore |
| `state_type` | Utf8 | e.g. `started`, `unstarted`, `completed` |
| `state_id` | Utf8 | State UUID |
| `priority` | Int64 | 0=No priority, 1=Urgent, 2=High, 3=Medium, 4=Low |
| `priority_label` | Utf8 | `Urgent`, `High`, `Medium`, `Low`, `No priority` |
| `assignee_name` | Utf8 | Assignee display name — NOTE: single underscore |
| `assignee_id` | Utf8 | Assignee UUID |
| `assignee_email` | Utf8 | Assignee email |
| `creator_name` | Utf8 | Creator display name |
| `team_key` | Utf8 | Team prefix e.g. `ENG` |
| `created_at` | Utf8 | ISO 8601 string |
| `updated_at` | Utf8 | ISO 8601 string |
| `started_at` | Utf8 | When work started, null if not started |
| `completed_at` | Utf8 | When completed, null if open |
| `canceled_at` | Utf8 | When canceled, null if not canceled |
| `due_date` | Utf8 | Due date string |
| `url` | Utf8 | Link to issue |
| `label_names` | Utf8 | Labels |
| `project_name` | Utf8 | Project name |

**Sample query (against mock):**
```sql
SELECT identifier, title, state_name, assignee_name, priority_label, updated_at, url
FROM linear.issues
WHERE state_name IN ('In Progress', 'In Review')
ORDER BY updated_at ASC
LIMIT 20
```

**⚠️ Critical gotcha — column naming:**
Linear uses **single underscore** (`state_name`, `assignee_name`) NOT double underscore (`state__name`).  
GitHub uses **double underscore** (`user__login`, `assignee__login`).  
Do NOT mix these up in queries.

---

## Slack

> ⚠️ Coral only exposes `slack.channels` and `slack.users` — NO messages table.  
> Using JSONL mock source `slack_messages` for demo.

### slack.channels (real)

**Required filters:** none

**Key columns:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `id` | Utf8 | Channel ID e.g. `C0B616280CF` |
| `name` | Utf8 | Channel name |
| `topic` | Utf8 | Channel topic |
| `purpose` | Utf8 | Channel purpose |
| `num_members` | Int64 | Member count |
| `is_archived` | Boolean | Whether archived |
| `created` | Int64 | Unix timestamp |

**Known channel IDs:**

| Channel name | ID |
|:-------------|:---|
| slack_channel | `C0B616280CF` |
| all-workspace | `C0B6GFP326N` |
| new-channel   | `C0B6GG6LYSE` |
| social        | `C0B7AQ5GPME` |

### slack.users (real)

| Column | Type |
|:-------|:-----|
| `id` | Utf8 |
| `name` | Utf8 |
| `real_name` | Utf8 |
| `display_name` | Utf8 |
| `email` | Utf8 |
| `is_admin` | Boolean |
| `is_bot` | Boolean |
| `deleted` | Boolean |

### slack_messages.messages (MOCK)

> Source: `./data/slack_messages.jsonl`  
> Added via: `coral source add --file sources/slack_messages.yaml`

**Required filters:** `channel`

| Column | Type | Notes |
|:-------|:-----|:------|
| `channel` | Utf8 | Channel ID — REQUIRED filter |
| `text` | Utf8 | Message content |
| `user` | Utf8 | Sender username |
| `ts` | Utf8 | Unix timestamp as string e.g. `1716800000.000001` |
| `thread_ts` | Utf8 | Parent message ts if reply, null otherwise |

**Sample query:**
```sql
SELECT text, user, ts, thread_ts
FROM slack_messages.messages
WHERE channel = 'C0B616280CF'
ORDER BY ts DESC
LIMIT 20
```

---

## Notion

> ⚠️ Using JSONL mock — real API may be connected but pages need to be shared with integration.

### notion.pages

**Required filters:** none

**Key columns for Drift:**

| Column | Type | Notes |
|:-------|:-----|:------|
| `id` | Utf8 | Page UUID |
| `page_id` | Utf8 | Page UUID (duplicate of id) |
| `object` | Utf8 | Always `page` |
| `created_time` | Utf8 | ISO 8601 string |
| `last_edited_time` | Utf8 | ISO 8601 string |
| `url` | Utf8 | Internal Notion URL |
| `public_url` | Utf8 | Public URL if published |
| `in_trash` | Boolean | Whether page is deleted |
| `properties` | Utf8 | Serialized JSON of page properties |
| `parent` | Utf8 | Parent page/database reference |

**Sample query:**
```sql
SELECT id, last_edited_time, url, in_trash
FROM notion.pages
WHERE in_trash = false
ORDER BY last_edited_time DESC
LIMIT 20
```

**Gotchas:**
- `properties` is a serialized JSON blob — you cannot directly query title from it via SQL
- Page title is NOT a direct column — it's inside `properties`
- Comments are NOT available through Coral — need direct Notion API if required
- Always filter `in_trash = false` to exclude deleted pages

**Other available Notion tables** (not primary for Drift):
- `notion.databases` — list of databases
- `notion.users` — workspace members
- `notion.search` — full-text search across pages
- `notion.block_children` — blocks inside a page
- `notion.data_sources` — data source list

---

## Cross-Source Timestamp Reference

| Source | Timestamp format | Example |
|:-------|:----------------|:--------|
| GitHub | ISO 8601 string | `2025-05-20T10:00:00Z` |
| Linear | ISO 8601 string | `2025-05-20T10:00:00Z` |
| Notion | ISO 8601 string | `2025-05-20T10:00:00.000Z` |
| Slack (real) | Unix Int64 | `1716800000` |
| Slack (mock) | Unix string | `1716800000.000001` |

---

## Column Naming Convention (CRITICAL for Person 2)

| Source | Style | Example |
|:-------|:------|:--------|
| GitHub | Double underscore `__` for nested | `user__login`, `assignee__name` |
| Linear | Single underscore `_` for nested | `state_name`, `assignee_name` |
| Notion | Flat columns only | `last_edited_time`, `in_trash` |
| Slack  | Flat columns only | `num_members`, `is_archived` |

---

## Demo Data Readiness Checklist

- [ ] GitHub returns open PRs → `SELECT * FROM github.pulls WHERE owner='AgroKING' AND repo='drift' AND state='open'`
- [ ] GitHub returns open issues → `SELECT * FROM github.issues WHERE owner='AgroKING' AND repo='drift' AND state='open'`
- [ ] GitHub returns commits → `SELECT * FROM github.commits WHERE owner='AgroKING' AND repo='drift' LIMIT 5`
- [ ] Linear mock returns issues → `SELECT * FROM linear.issues LIMIT 5`
- [ ] Slack mock returns messages → `SELECT * FROM slack_messages.messages WHERE channel='C0B616280CF' LIMIT 5`
- [ ] Notion pages returns rows → `SELECT * FROM notion.pages LIMIT 5`
