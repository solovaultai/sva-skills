---
name: promptify
description: >
  Promptify — rewrite the user's prompt on claude.ai. Returns the
  rewritten prompt and does not execute it. Use only when the user invokes
  promptify.
license: All rights reserved
compatibility: claude.ai chat. No shell and no local skill scripts.
metadata:
  pack: claude-web
  version: "1.0"
allowed-tools: ""
---

# Promptify

Run this only when the user invokes promptify on claude.ai. Do not load it on your own.

Rewrite the user's prompt. Do not execute it. Do not answer the underlying question, write a plan, or debug.

## What to do

1. Name the outcome they want, the constraints they stated, and anything they left unknown.
2. Rewrite one prompt they could send in a later turn. Keep their names, paths, and quoted tokens. Do not invent files, APIs, tools, or datasets.
3. Print the rewritten prompt in one fenced block, then at most three short notes on what you clarified.
4. Stop. Do not run the rewritten prompt.

## Do not

- Carry out the task the prompt describes.
- Edit files or apply a fix.
- Pretend another skill file was loaded.
