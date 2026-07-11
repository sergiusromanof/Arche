---
id: branch
description: Create a branch following a <prefix>/<ticket>/<slug> convention
targets: claude codex generic
tags: git
argument-hint: "<ticket-or-url> [base-branch] [--push]"
allowed-tools: Bash(git:*), Bash(gh:*), Read
---

Create a new branch named `<prefix>/<ticket>/<n>-<slug>` (for example `alex/482/0-token-refresh`). Nothing here is project-specific — detect everything from the repository and the ticket.

## Step 1 — Parse the arguments

From the command arguments:

- **First token (required)** — the ticket: either a bare number (`482`) or an issue URL. To get the number: if the value contains `/issues/<n>`, use that captured `<n>`; otherwise if it is all digits, use it as-is; otherwise stop and ask. Do not just take trailing digits — a URL like `.../issues/482#issuecomment-99` must resolve to `482`, not `99`.
- **Second token (optional)** — an explicit base branch. If given, use it verbatim.
- **`--push` (optional, anywhere)** — after creating the branch, push it with `git push -u origin <branch>`.

## Step 2 — Resolve the prefix

1. If `~/.config/arche/config` sets `BRANCH_PREFIX`, use it.
2. Otherwise use the local part (before `@`) of `git config user.email`.

## Step 3 — Resolve the base branch

1. If a base branch was passed, use it.
2. Otherwise, if `~/.config/arche/config` sets `BRANCH_BASE`, use it.
3. Otherwise use the remote's default branch: run `git symbolic-ref --quiet refs/remotes/origin/HEAD` and take the last path segment, or run `git remote show origin` and read its `HEAD branch:` line.
4. If none of the above resolves, fall back to the current branch, and warn.

## Step 4 — Build the slug

Fetch the ticket title: `gh issue view <ticket> --json title -q .title`.

- **On success:** lowercase the title, replace every run of non-alphanumeric characters with `-`, strip leading/trailing dashes, and keep the **first 2–4 words** (prefer fewer for long titles).
- **On failure** (no `gh`, ticket not found, or offline): ask the user to type a slug.

## Step 5 — Compute `<n>`

Refresh remotes so the count includes teammates' branches: `git fetch --prune origin` (ignore errors). Then count existing branches matching `<prefix>/<ticket>/*` across local and remote, de-duplicated. That count is `<n>` (none existing → `0`, one → `1`, …).

## Step 6 — Confirm, then create

Show the proposed full name, base, and slug, and let the user accept or replace the slug:

```
Proposed: <prefix>/<ticket>/<n>-<slug>
Base:     <base>
Slug:     <slug>   (Enter to accept, or type a new one)
```

Then create it:

1. Verify the branch does **not** already exist locally or on origin (`git show-ref --verify --quiet refs/heads/<name>` and `.../remotes/origin/<name>`). If either exists, stop and say where — do not auto-bump `<n>`.
2. `git checkout -b <name> <base>`.
3. If `--push` was passed, `git push -u origin <name>`.

Print the created branch name and the push result if pushed.

## Config overrides

Optional keys in `~/.config/arche/config`: `BRANCH_PREFIX`, `BRANCH_BASE`, and `BRANCH_PATTERN` (to change the `<prefix>/<ticket>/<n>-<slug>` shape).
