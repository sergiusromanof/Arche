---
id: review
description: Run a code review and report only a compact table with safe fixes
targets: claude codex generic
tags: quality
argument-hint: "[target: diff (default) | <file> | <PR number>]"
allowed-tools: Bash(git:*), Bash(gh:*), Read, Grep, Glob
---

Perform a thorough code review of the target and report the result as **only a table** — nothing before or after it. This wraps the built-in code review; if a `/code-review` command or skill is available, use it to do the analysis, otherwise review the diff yourself with the same rigor.

## Target

- No argument → the current working diff (`git diff` and staged changes).
- A file path → review that file.
- A number → review that pull request's diff.

## Output — table only

Report every real issue, most severe first, as this table and nothing else:

| Severity | Where | Bug | Suggested safe fix |
|----------|-------|-----|--------------------|
| High / Medium / Low | `file:line` | one plain sentence, no jargon | the smallest safe change |

Rules:

- **Plain language.** Describe the bug in one sentence a non-expert can follow — what goes wrong, not the theory.
- **Minimal detail.** Only the essential; no reproduction essays, no restating the code.
- **Safe fixes.** Each suggested fix must be the smallest, most local, side-effect-free change that resolves the bug **without introducing a new one**. Prefer fixing the root cause over patching a symptom. If a fix needs a test to be safe, say so in the fix cell.
- **Severity** reflects impact: `High` = wrong result, crash, data loss, or security; `Medium` = wrong in edge cases; `Low` = minor correctness or robustness.
- Do not include style-only nits unless they cause a real bug.

If there are no real issues, output a single line: `No issues found.` — no table, no other text.
