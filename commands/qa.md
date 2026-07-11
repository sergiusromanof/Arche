---
id: qa
description: Turn a change into a plain-language test ticket for a non-developer QA tester
targets: claude codex generic
tags: testing
argument-hint: "[ticket number or URL]"
allowed-tools: Bash(git:*), Bash(gh:*), Read
---

Write a clear, human-readable test ticket that a non-developer tester can follow. Translate developer changes into plain language — no class names, no methods, no architecture. Testers think in screens, buttons, and actions, not code.

## Gather context

1. **Find the source ticket:** take it from the argument, or extract it from the branch name / recent commits. Read it: `gh issue view <ticket>`. Understand what was asked and why.
2. **Find related pull requests:** `gh pr list --search <ticket> --state all --json number,title,url`, then read each with `gh pr view <n>` and `gh pr diff <n>` to see what actually changed.
3. **Translate to user-visible behavior:** what does a user see or do differently? What was broken before, and how does it work now? If a change is invisible to users (backend, logging), say so and how to verify it.

## Where to create it

- If `~/.config/arche/config` sets `QA_REPO`, create the ticket there: `gh issue create --repo <QA_REPO> ...`. Otherwise create it in the current repository.
- If `QA_BOARD` is set, add the new issue to it with `gh project item-add <QA_BOARD> --owner <owner> --url <issue-url>`.
- Assign it to the change's author (from the pull request, e.g. `gh pr view <n> --json author -q .author.login`) or to yourself, then return the ticket URL.

## Ticket body

```markdown
## What changed
<Plain English: what the user will notice. Use "the app / the page / the button", not code.
If a bug fix: what was broken and how it works now. If a feature: what the user can now do.>

## What to verify
<A short description of what to test — enough context for the tester to choose their own steps.
Cover both the happy path and what should happen when things go wrong.>

## Edge cases
<Only the ones relevant to this change — delete the rest:>
- [ ] Small vs large screens / window sizes
- [ ] Different OS or browser versions
- [ ] Dark vs light mode
- [ ] Offline / slow connection / returning from background (if it touches the network)
- [ ] New user vs existing user, empty vs full state
- [ ] Different languages / locales, right-to-left layouts
- [ ] Upgrading from an older version (if data or settings migrate)

## Regression areas
<Other parts of the product that could be affected as a side effect, even if not directly changed.>

## Links
<The source ticket and each related pull request, one link per line.>
```

## Writing rules

- No code jargon — never mention classes, methods, frameworks, databases, or patterns.
- Be specific about location — "the Settings page → Notifications section", not "the settings flow".
- Include both what should work and what should happen on failure.
- Use checkboxes for edge cases so the tester can tick them off.
- Keep only the edge-case and section rows that actually apply to this change.

If you cannot tell what the user experiences differently, ask: "What does the user see or do differently after this change?"
