---
id: prove-your-work
description: Back claims with evidence and verify that fixes introduce no new problems
targets: claude codex generic
tags: engineering
---
## Prove your work

- Back factual claims with evidence: if you assert a file size, a duration, or a speedup, show the log or measurement behind it.
- When you claim an improvement, show the before-and-after.
- A fix must not create new problems: after each change, re-run the relevant check, confirm the original issue is gone, and confirm nothing else broke.
- Work in small steps so a regression is easy to spot.
