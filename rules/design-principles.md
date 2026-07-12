---
id: design-principles
description: Apply the classic design principles — KISS, YAGNI, DRY, SOLID, and more
targets: claude codex generic
tags: engineering
---
## Apply the classic design principles

- KISS — keep the design as simple as the problem allows; prefer the straightforward solution over a clever one.
- YAGNI — build only what the current task needs, not what you imagine it might need later.
- DRY — remove needless duplication, but do not force a shared abstraction on things that merely look alike.
- Single responsibility (the S in SOLID) — give each function, module, or type one clear job and one reason to change.
- Separation of concerns — keep unrelated concerns such as logic, I/O, and presentation in separate units.
- Prefer composition over inheritance — assemble behavior from small pieces instead of deep class hierarchies.
- Least astonishment — make code behave the way its name and context lead a reader to expect.
- Fail fast — validate inputs and surface errors early and clearly instead of letting them propagate silently.
