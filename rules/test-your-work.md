---
id: test-your-work
description: Cover behavior with honest tests and never weaken tests just to pass
targets: claude codex generic
tags: engineering
---
## Test your work honestly

- Cover new behavior with tests that assert what the code should do, not what it happens to do.
- Do not weaken, skip, or delete an existing test just to make the suite pass; if a test fails, understand why first.
- When fixing a bug, first write a test that reproduces it, then change the code until that test passes.
- Keep tests independent and repeatable, with realistic data and no shared state between them.
