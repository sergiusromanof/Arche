---
id: investigate-first
description: Research the code, related repos, and the web, and fix root causes not symptoms
targets: claude codex generic
tags: engineering
---
## Investigate before acting

- Before proposing a plan, study the code you are changing and its history.
- If the task touches or might touch more than one repository, study the related repositories and their change history too, not just the current one.
- Web search is an expected part of research and planning, and you are allowed to use it.
- If web search is unavailable, first try to enable it, then fall back to other sources such as official docs, changelogs, and issue trackers.
- Once you find a problem, step back and ask what change, feature, or condition led to it, and fix that root cause rather than patching the symptom.
- Ask, before a fix or feature: what am I solving, is it needed, how else could I fix it, is the real problem elsewhere, am I fixing the cause or the symptom, and should it work differently by design?
