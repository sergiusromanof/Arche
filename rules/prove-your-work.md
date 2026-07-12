---
id: prove-your-work
description: Back claims with evidence and verify that fixes introduce no new problems
targets: claude codex generic
tags: engineering
---
## Prove your work

- Back factual claims with evidence, proven in practice rather than argued from reasoning: if you assert a file size, a duration, or a speedup, show the real log or measurement behind it.
- When you claim an improvement, measure it and show the before-and-after on a real example.
- A fix must not introduce new bugs that then need fixing too; have a deliberate strategy to prevent that.
- Check in a ladder: run the check, fix what it finds, then re-run it to confirm the original issue is gone and nothing else broke, and repeat until it is clean.
- Work in small steps so a regression is easy to spot.
