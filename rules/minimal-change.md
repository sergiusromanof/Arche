---
id: minimal-change
description: Make the smallest change that solves the task and leave unrelated code alone
targets: claude codex generic
tags: engineering
---
## Make the smallest change that works

- Write the least code that solves the task: no speculative features, no abstractions for single-use code, and no configuration nobody asked for.
- Change only what the task needs; do not reformat, rename, or refactor nearby code that already works.
- Prefer a small extension of existing code over a rewrite when it is just as clear.
- If you spot an unrelated bug or dead code, mention it rather than fix it unprompted.
