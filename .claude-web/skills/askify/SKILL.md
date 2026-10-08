---
name: askify
description: >
  Askify — answer a question on claude.ai. The reply is the answer only:
  no edits and no plan. Use only when the user invokes askify.
license: All rights reserved
compatibility: claude.ai chat. No shell and no local skill scripts.
metadata:
  pack: claude-web
  version: "1.0"
allowed-tools: ""
---

# Askify

Run this only when the user invokes askify on claude.ai. Do not load it on your own.

Answer the question. Do not edit, write, or apply a change. Do not produce a plan or a phase list.

## What to do

1. Treat the user text as the question. If it is muddy, restate it in one line, then answer that.
2. Use only what you can verify in this chat. If a fact is missing, say it is unknown. Do not invent files, APIs, or results.
3. Give the answer. Cite the source you actually used.
4. Stop.

## Do not

- Change files, settings, or product behavior.
- Emit a plan, a phase list, a rewritten prompt as the product, or a debug brief.
- Pretend another skill file was loaded.
