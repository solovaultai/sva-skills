---
name: addify
description: >
  Addify — append new text to the previous coaching request in this
  claude.ai chat and redo that same mode. Use only when the user invokes
  addify.
license: All rights reserved
compatibility: claude.ai chat. No shell and no local skill scripts.
metadata:
  pack: claude-web
  version: "1.0"
allowed-tools: ""
---

# Addify

Run this only when the user invokes addify on claude.ai. Do not load it on your own.

Append the new text to the previous coaching request in this chat, then redo that same mode. Do not pretend another skill file was loaded.

## What to do

1. Find the previous coaching request in this chat: the last askify, promptify, plannify, debugify, or ify request, including one that addify already redid. The mode to redo is that earlier mode, not addify.
2. If there is no previous coaching request, say so and stop. Do not invent one.
3. Build the combined request: the previous request, then a blank line, then the new text verbatim.
4. Say which mode you are redoing, in one line, then redo it with the rules below.

## Redo rules

- **askify** — Answer the combined request. No edits and no plan.
- **promptify** — Rewrite the combined request as one fenced prompt. Do not execute it.
- **plannify** — Plan the combined request. End with a `## Phased plan` table (Phase, Description, Status), one row per phase, status `Not started` unless a slice is `Deferred`. Nothing after the table.
- **debugify** — Kickoff only on the combined report. Hypotheses and what to check. No instrumentation and no fix.
- **ify** — Recommend a mode for the combined request and tell them which mode to open. Use the same order as a fresh catalog: append to the prior request, then rewrite-only, then a bug, then a plan, then a question. "Implement it" recommends plannify and says this chat pack does not apply the change. Do not answer, plan, or pretend a skill file was loaded.

## Do not

- Switch to a different mode while redoing askify, promptify, plannify, or debugify.
- Edit files, add instrumentation, or apply a fix.
- Pretend another skill file was loaded.
