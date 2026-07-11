---
id: status-update
description: Summarize a person's GitHub activity for a period into a clear status update
targets: claude codex generic
tags: git
argument-hint: "[period: today (default) | yesterday | week | since YYYY-MM-DD]"
allowed-tools: Bash(git:*), Bash(gh:*), Read
---

Gather a person's activity over a time period and write a clear, structured status update they can paste into a standup or a channel. Default period: **today**.

## Who and when

- **Who:** the authenticated user (`gh api user -q .login`), unless `~/.config/arche/config` sets `STATUS_USER`.
- **Period:** from the argument — `today` (default), `yesterday`, `week` (the last 7 days), or `since <YYYY-MM-DD>`. Compute the start date and use it below.

## Gather the activity (across repositories)

Collect what the person did since the start date. Skip any source that returns nothing — never invent activity. Adapt the exact flags to the installed `gh` version:

- **Pull requests opened or merged:** `gh search prs --author <user> --created ">=<start>"` (also look for merged ones).
- **Issues opened:** `gh search issues --author <user> --created ">=<start>"`.
- **Reviews given:** `gh search prs --reviewed-by <user> --updated ">=<start>"`.
- **Comments and other events:** `gh api "/users/<user>/events?per_page=100"` and keep the events dated on or after the start date (issue/PR comments, reviews, pushes). For anyone other than the authenticated user this returns only public events — note that in the summary if it applies.
- **Commits in the current repo:** `git log --author <user> --since <start> --pretty='%h %s'`.

Request JSON where the tool supports it, so you get titles, URLs, repositories, and timestamps to work with.

## Write the update

Produce a short, readable summary. Include **only the sections that have content**:

```markdown
# Status update — <period, e.g. 2026-07-12>

## Merged
- <title> — <repo> (<link>)

## In progress / opened
- <title> — <repo> (<link>)

## Reviews
- <title> — <repo> (<link>)

## Commits
- <short sha> <subject>

## Notes
<one or two lines of context or blockers — only if useful>
```

Rules: plain language, grouped by kind, one line per item with a link, newest first. No filler and no restating the obvious. If there was no activity in the period, say so in a single line.

## Config overrides

Optional keys in `~/.config/arche/config`: `STATUS_USER` (whose activity to summarize) and `STATUS_SINCE` (a default period).
