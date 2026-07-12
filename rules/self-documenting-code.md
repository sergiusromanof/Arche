---
id: self-documenting-code
description: Write code that reads without comments, and comment only the non-obvious
targets: claude codex generic
tags: engineering
---
## Self-documenting code

- Write code that reads without comments: names and structure should make the intent obvious on their own.
- Name things for their purpose, not their type — prefer `activeUsers` or `calculateTax()` over `data`, `tmp`, or `doStuff()`.
- Replace magic numbers and unexplained literals with named constants.
- Extract a complex condition or block into a well-named function instead of explaining it with a comment.
- Comment the *why*, not the *what*: the reason for a decision, a business rule, a workaround, a surprising behavior, or a non-obvious trade-off.
- A comment that explains *how* the code works is usually a sign the code should be simplified instead.
- Self-documenting does not mean comment-free — keep the comments that add real understanding.
- Keep comments to one sentence per line; never wrap a single sentence across lines or pad them with filler.
