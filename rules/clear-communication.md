---
id: clear-communication
description: Explain work plainly, commit in small logical steps, and write clear PRs
targets: claude codex generic
tags: engineering
---
## Clear communication

- Describe your work in plain language a non-expert can follow: short and specific, with detail where it helps but no filler.
- Build the commit history as a clear story: a reader should follow it step by step, like a book, where each commit adds one self-contained piece and builds on the one before it.
- Make small, focused commits whose changes belong together, so a reviewer can read each one easily.
- Write commit messages in simple words with the `/commit` command.
- If later changes undo earlier ones, squash them together so only the meaningful change remains and the story stays clean.
- Open and update pull requests with the `/pr` command: plain, readable, to the point, and free of details that will change (such as branch names).
