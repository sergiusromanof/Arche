# Arche

Portable collection of AI skills, scripts, prompts, commands, agents, and rules — installable into Claude Code, Codex, and local AI setups with a zero-dependency Bash installer.

Arche keeps one source-of-truth collection of AI assets and installs each into the right place and format for whichever AI system you use.
It favors placement over transformation, symlinks over copies (so `git pull` updates everything live), and it is safe by default and idempotent.

## Supported targets

| Target | Where it installs |
|--------|-------------------|
| **Claude Code** | `~/.claude/` (skills, commands, agents, prompts) + `CLAUDE.md` for rules |
| **Codex (OpenAI)** | `~/.codex/` (skills, prompts) + `AGENTS.md` for rules |
| **Generic / local** | `~/.config/arche/` (tool-agnostic layout) + `RULES.md` |

Scripts install to `~/.local/bin` on every target. See [`docs/targets/`](docs/targets) for per-target details.

## Asset types

`skills`, `scripts`, `prompts`, `commands`, `agents`, `rules`. New types can be added later without a redesign.

## Repo layout

```
arche/
  install.sh              # CLI dispatcher + `arche` shim installer
  lib/
    core.sh               # engine: discovery, metadata, place, manifest, blocks, config
    adapters/             # one file per target: claude.sh, codex.sh, generic.sh
  skills/ scripts/ prompts/ commands/ agents/ rules/   # source-of-truth assets
  profiles/               # named bundles of assets
  templates/              # skeletons showing each asset format
  test/                   # bats integration tests + fixtures
  docs/                   # per-target guides, generated catalog
```

## Asset format

Every markdown asset carries single-line frontmatter:

```
---
id: my-skill
description: One line describing the asset
targets: claude codex generic
tags: example
---
```

Scripts declare metadata via `# arche-targets:` / `# arche-description:` comments and default to all targets.

## Quick start

> The installer (`install.sh`) arrives in a later milestone.

```
git clone https://github.com/sergiusromanof/Arche.git
cd Arche
./install.sh --install-shim     # adds `arche` to ~/.local/bin
arche setup                     # one-time configuration
arche install claude            # install everything for Claude Code
arche list                      # see available assets
```

## Safety

Arche is safe by default: `--dry-run` previews every action, files are backed up before any edit, a manifest enables exact uninstall, it never overwrites files it did not create, it never executes your scripts, and it refuses to run as root.
Permission modes: `interactive` (default), `allow-all` (`--yes`), `restricted`.

## License

MIT — see [`LICENSE`](LICENSE).
