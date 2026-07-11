---
id: investigate-first
description: Research the code, related repos, and the web, and fix root causes not symptoms
targets: claude codex generic
tags: engineering
---
## Investigate before acting

- Before proposing a plan, study the code you are changing and its history.
- If the task may touch more than one repository, study the related repositories and their change history too, not just the current one.
- Treat web search as a normal part of research and use it; if it is unavailable, try to enable it or fall back to other sources such as official docs, changelogs, and issue trackers.
- Once you find a problem, step back and ask what change, feature, or condition led to it, and fix that root cause rather than the symptom.
- Before building a fix or feature, ask yourself: what am I solving, is it actually needed, could the real problem be elsewhere, and am I addressing the cause or only a symptom?
