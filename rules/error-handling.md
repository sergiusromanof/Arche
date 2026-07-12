---
id: error-handling
description: Handle errors deliberately — never swallow them, fail loudly, and preserve the cause
targets: claude codex generic
tags: engineering
---
## Handle errors deliberately

- Never swallow an error: handle it, propagate it, or log it with context — an empty catch that hides the failure is a bug.
- Fail loudly with a message that says what went wrong and gives enough context to act on, not a generic "something failed".
- Catch the most specific error you can handle, not a broad catch-all that also hides bugs you did not expect.
- When wrapping an error, keep the original cause so the stack trace and root reason are not lost.
- Release resources on every path with try/finally or the language's equivalent (defer, with, RAII), including the error path.
- Do not use errors for normal control flow; handle each error at the level that can actually do something about it.
