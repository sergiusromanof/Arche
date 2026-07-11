---
id: investigate
description: Research a problem or question in depth and report a clear, well-sourced answer
targets: claude codex generic
tags: research
argument-hint: "<problem or question to investigate>"
allowed-tools: WebSearch, WebFetch, Read, Grep, Glob, Bash(git:*), Bash(gh:*)
---

Investigate the problem or question thoroughly and report what you actually found — the root cause, or the answer, with evidence. Do not stop at the first plausible explanation; dig until you understand *why*.

## Frame it first

State, in one or two lines, what you are trying to find out and how you'll know when you've found it. If the request is ambiguous, ask one focused question before spending effort.

## Investigate from several angles

Gather evidence from more than one source — a single angle usually misses the real cause:

- **This codebase:** read the relevant code, and its history (`git log -p`, `git blame`) — a change, feature, or dependency often introduced the problem.
- **Related repositories and resources:** if the topic touches other repos, services, or configs, look at those too (`gh` for issues/PRs/releases in related repos).
- **The web:** search for the error, API, symptom, or question. Web search is a normal part of research — use it. If it is unavailable, try to enable it, otherwise fall back to other sources (official docs, changelogs, issue trackers) and say what you couldn't reach.
- **Cross-check:** confirm each claim against a second source or a direct observation. Prefer evidence (a log line, a test, a commit, a doc) over assumption.

## Find the real cause, not a symptom

Once you have a lead, step back and ask: what change, feature, or condition led to this? Keep asking until the answer holds up:

- What am I actually solving? Does it need solving?
- Am I fixing the root cause or patching a symptom?
- Could the real problem be somewhere else, or should this work differently by design?

## Report

Write a clear, readable report — plain language, maximum useful signal, no filler:

```markdown
## Question / problem
<what you set out to find>

## Answer / root cause
<the finding, stated plainly and up front>

## Evidence
<the concrete things that support it — logs, code, commits, docs — each with where it came from>

## How it happened *(for a problem)*
<the change / feature / condition that led to it>

## Recommendation *(if applicable)*
<what to do, and why this addresses the cause rather than the symptom>

## Sources
<links to the pages, repos, issues, or files you relied on>
```

If you could not reach a confident conclusion, say so, give the most likely explanations ranked by evidence, and state what would confirm each.
