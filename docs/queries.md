# Drift Debt Queries

These are the Person 2 query templates for the five debt categories. They use
`:user` as the current-user parameter. Person 1 can update table or field names
after Coral schema discovery without changing the debt scoring code.

## Review Debt

```sql
SELECT
  pr.number AS pr_number,
  pr.title AS title,
  pr.author AS author,
  pr.repository AS repo,
  DATE_DIFF('day', pr.review_requested_at, CURRENT_TIMESTAMP) AS days_waiting,
  COALESCE(slack.mention_count, 0) AS slack_mentions,
  linear.issue_key AS blocks,
  pr.url AS url
FROM github_pull_requests pr
LEFT JOIN slack_pr_mentions slack ON slack.pr_url = pr.url
LEFT JOIN linear_blocked_issues linear ON linear.blocking_pr_url = pr.url
WHERE pr.state = 'open'
  AND pr.review_requested_from = :user
ORDER BY days_waiting DESC, slack_mentions DESC;
```

## Reply Debt

```sql
SELECT
  message.source AS source,
  message.channel AS channel,
  message.sender AS "from",
  DATE_DIFF('day', message.created_at, CURRENT_TIMESTAMP) AS days_ago,
  message.preview AS preview
FROM unanswered_messages message
WHERE message.assignee = :user
  AND message.needs_response = TRUE
ORDER BY days_ago DESC;
```

## Commitment Debt

```sql
SELECT
  issue.key AS task_id,
  issue.title AS title,
  issue.status AS status,
  DATE_DIFF('day', issue.updated_at, CURRENT_TIMESTAMP) AS days_stale,
  github.last_commit_date AS last_commit_date
FROM linear_issues issue
LEFT JOIN github_issue_activity github ON github.issue_key = issue.key
WHERE issue.assignee = :user
  AND issue.status IN ('In Progress', 'Todo', 'Blocked')
ORDER BY days_stale DESC;
```

## Staleness Debt

```sql
SELECT
  pr.number AS pr_number,
  pr.title AS title,
  pr.repository AS repo,
  DATE_DIFF('day', pr.updated_at, CURRENT_TIMESTAMP) AS days_stale,
  COALESCE(pr.review_count, 0) AS reviews,
  pr.url AS url
FROM github_pull_requests pr
WHERE pr.author = :user
  AND pr.state = 'open'
ORDER BY days_stale DESC;
```

## Drift Debt

```sql
SELECT
  issue.key AS task_id,
  issue.title AS task_title,
  issue.status AS task_status,
  pr.number AS pr_number,
  pr.state AS pr_status,
  CONCAT('Task marked ', issue.status, ' in Linear but PR #', pr.number, ' is ', pr.state) AS contradiction
FROM linear_issues issue
JOIN github_pull_requests pr ON pr.linked_issue_key = issue.key
WHERE issue.assignee = :user
  AND issue.status IN ('Done', 'Completed', 'Closed')
  AND pr.state != 'merged';
```
