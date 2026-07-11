# Contributing to Arche

Thanks for helping grow the collection. Arche is a source-of-truth set of AI assets plus a zero-dependency Bash installer.

## Adding an asset

Assets live in the typed folders at the repo root: `skills/`, `scripts/`, `prompts/`, `commands/`, `agents/`, `rules/`.

Markdown assets carry single-line frontmatter:

```
---
id: my-asset
description: One line describing what it does
targets: claude codex generic
tags: optional space separated
---
```

- `targets` is a space-separated list on one line: any of `claude`, `codex`, `generic`.
- A skill is a folder `skills/<id>/` containing `SKILL.md` plus any supporting files.
- Scripts declare metadata via comments (`# arche-targets:`, `# arche-description:`) and default to all targets.

See `templates/` for a starting point per type. After adding assets, regenerate the catalog with `./install.sh docs`.

## Adding a target adapter

Each target is one file, `lib/adapters/<target>.sh`, implementing four functions:

- `adapter_<t>_root` — base install directory (honor `ARCHE_TARGET_DIR`).
- `adapter_<t>_supports <type>` — return 0 if the target handles that asset type.
- `adapter_<t>_dest <type> <id>` — destination path for an asset.
- `adapter_<t>_rulefile` — file that receives `rules`.

Then add the target name to `arche_valid_target` in `lib/core.sh`.

## Running tests and lint

```
bats test/
shellcheck -x -P SCRIPTDIR install.sh lib/*.sh lib/adapters/*.sh
```

Both run in CI on Linux and macOS. Tests use fixtures under `test/fixtures/` and an isolated `$HOME`, so they never touch your real configuration.

## Commits and pull requests

- Use Conventional Commits: `<type>(<issue>): <subject>` — for example `feature(012): add a git-bisect skill`. Types: `feature`, `fix`, `docs`, `test`, `ci`, `chore`, `refactor`.
- Keep commits small and focused; each should pass tests and lint.
- Open one PR per change with a clear description. CI must be green before merge.
