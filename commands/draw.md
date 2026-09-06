---
id: draw
description: Draw a diagram of what the code actually does and show it in the chat
targets: claude codex generic
tags: diagrams
argument-hint: "<what to draw — a flow, an architecture, a change>"
allowed-tools: Read, Grep, Glob, Bash(drawio:*), Bash(git:*), Bash(gh:*), WebFetch
---

Draw a diagram that is true to the code, and put it in front of the reader as an image.
A diagram is read as fact, so an invented box is worse than no diagram at all — everything you draw has to come from something you read.

## Know what you are drawing

If the subject already exists in the code, read it before you draw a single box.
Find the real entry point and follow it: `grep` for the type or function, read the file, and check `git log -p` when the *why* is unclear.
Never draw from a file name, a folder name, or memory of a similar project — those are guesses wearing the costume of facts.

If the subject does not exist yet — a design, a refactor, a plan — say so in one line above the diagram, so nobody mistakes a proposal for the current state.

When the code contradicts the request, draw the code and say what surprised you.
That mismatch is usually the most valuable thing you produce.

## One idea per diagram

Decide what single question the diagram answers, and cut everything that does not help answer it.
A reader takes in about a dozen boxes; past that the picture stops being a shortcut and becomes homework.

- Too big to fit? Draw two diagrams — one overview, one zoomed into the part that matters.
- Repeated identical branches? Draw one and label the multiplicity.
- Error paths, retries, and logging usually belong in a second diagram, not the first.

Match the shape to the question: a flow for "what happens when…", a sequence for "who talks to whom, in what order", a class or ER diagram for "how is this structured", a layered box diagram for "where does this code live".

Write the labels in the language the reader uses, and in their words — screen names and domain terms, not class names, unless the reader is looking at the code.

## Build it

Write Mermaid and let draw.io lay it out — its parser positions everything, which beats hand-placed coordinates every time.
Reach for draw.io XML only when you need specific shape libraries (AWS, Azure, network, UML detail) or exact placement; then let the layout engine do the positioning anyway with `--layout verticalFlow` (or `horizontalFlow`, `verticalTree`, `organic`).

```bash
drawio -x -f xml -o NAME.drawio NAME.mmd                       # Mermaid -> editable .drawio
drawio -x -f xml --layout verticalFlow -o NAME.drawio NAME.drawio   # auto-layout XML you wrote
drawio -x -f png -e -b 10 -o NAME.drawio.png NAME.drawio        # PNG carrying the editable diagram
```

The `-e` flag embeds the diagram inside the PNG, so the image the reader looks at is also the file they can open and rearrange.
Delete the intermediate `.mmd` — the `.drawio` is the artifact.

Syntax you are unsure about is documented, so look it up instead of guessing:
[Mermaid](https://raw.githubusercontent.com/jgraph/drawio-mcp/main/shared/mermaid-reference.md) ·
[draw.io XML](https://raw.githubusercontent.com/jgraph/drawio-mcp/main/shared/xml-reference.md).

The command is `drawio` when draw.io Desktop is on the `PATH`, otherwise `/Applications/draw.io.app/Contents/MacOS/draw.io` on macOS or `C:\Program Files\draw.io\draw.io.exe` on Windows.
No draw.io at all? Write the `.drawio` file anyway — it opens in the free web editor — and tell the reader you could not render an image.

## Deliver

Export a PNG and show it in the chat — a path the reader has to go open is a diagram that never gets looked at.
Keep the `.drawio` next to it so the diagram can be edited later rather than redrawn from scratch.

Write both files to `DIAGRAMS_DIR` from `~/.config/arche/config` if it is set, otherwise the current directory.
Name the file after the thing, in lowercase with hyphens: `login-flow.drawio`, `login-flow.drawio.png`.

Look at the PNG you produced before you hand it over.
Overlapping boxes, clipped labels, and edges crossing the wrong node are obvious in the image and invisible in the source.

## Report

```markdown
![<title>](<path to the PNG>)

**<one line: what the diagram answers>**
<If it is a proposal and not the current code, say so here.>

## Where this comes from
<The files, functions, or commits you read, one per line — enough for the reader to check you.>

## What I left out
<The parts you deliberately cut to keep it readable, and where they would go.>

## What I could not confirm *(only if true)*
<Anything drawn from a reasonable inference rather than something you read.>
```

If the request is too vague to draw one clear picture — "diagram the app" — ask which question the diagram should answer before spending the effort.
One focused question now saves a diagram nobody can use.
