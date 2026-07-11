---
id: pr
description: Push the branch and open or update a clear, human-readable pull request
targets: claude codex generic
tags: git
argument-hint: "[extra context]"
allowed-tools: Bash(git:*), Bash(gh:*), Read
---

Push the current branch and create — or update — a pull request whose description a person can just read. Never mention AI, assistants, or tooling anywhere in the PR.

## Never duplicate a PR

First: `gh pr list --head <branch> --state all --json number,title,state,url`.

- If a PR already exists, **update it** with `gh pr edit <number>` (title and body). Never open a second one.
- If none exists, create one with `gh pr create` (add `--draft` when `~/.config/arche/config` sets `PR_DRAFT=on`).

## Find the base branch — do not assume

Detect the real base instead of guessing `main`:

1. If a PR exists, use its base.
2. Otherwise use the branch's upstream: `git config --get branch.<branch>.merge`.
3. Otherwise the remote's default branch (`git symbolic-ref --quiet refs/remotes/origin/HEAD`, last segment).
4. Fall back to `main` or `master` only if nothing else resolves.

## Gather context

- `git branch --show-current`
- `git log <base>..HEAD` — read the **full** commit messages and their reasons, not just `--oneline`.
- `git diff <base>...HEAD --stat` — the file-level shape of the change.
- Extract a ticket/issue number from the branch name or commit messages if the repo uses them.

## Push safely

Before pushing, check the remote isn't ahead: `git fetch origin <branch>` then `git log HEAD..origin/<branch> --oneline`.

- If the remote has extra commits, warn and ask before force-pushing.
- Otherwise `git push -u origin <branch>`.
- If the push fails, stop and report — do not proceed to create the PR.

Also run `git status` first; if there are uncommitted changes, warn the user (they may want to commit or stash).

## Write the description — plain and to the point

Write for a person who just wants to understand the change by reading, not a changelog.

- **Title:** `<What was done>` — a short, plain statement. Add the ticket as `(#<n>)` only if the repo uses ticket numbers.
- **Body sections:**
  - **What & why** — what changed and the reason, in plain language. Cover every meaningful commit's intent; don't drop reasons.
  - **Notes** *(optional)* — decisions, caveats, or migration steps a reviewer should know. Omit if there's nothing.
- **Links** — link the issue and any relevant resource (design, doc, related PR) so the reader can follow up.

Writing rules:
- Plain, human-readable language. No filler, no "this PR does…" throat-clearing, no restating the obvious.
- **No volatile details** — never put branch names, line numbers, or anything that changes over time into the body.
- Group related commits into single logical points; skip trivial mechanical noise (e.g. "updated imports across N files").
- Wrap code identifiers in backticks. Never add any AI or co-author attribution.

## After

- Assign the PR to its author unless `PR_ASSIGN_SELF=off`: `gh pr view <number> --json author -q .author.login`, then `gh pr edit <number> --add-assignee <author>` if unassigned.
- Return the PR URL. No extra commentary unless something went wrong.

## Config overrides

Optional keys in `~/.config/arche/config`: `PR_DRAFT` (create as a draft when `on`; default off) and `PR_ASSIGN_SELF` (assign to the author; default on).
