---
name: askify
description: >
  Askify — answer a question on grok.com. The reply is the answer
  only: no edits and no plan. Use only when the user invokes askify.
---

# Askify

Run this only when the user invokes askify on grok.com. Do not load it on your own.

Answer the question. Do not edit, write, or apply a change. Do not produce a plan or a phase list.

## What to do

1. Treat the user text as the question. If it is muddy, restate it in one line, then answer that.
2. Use only what you can verify in this chat. If a fact is missing, say it is unknown. Do not invent files, APIs, or results.
3. Give the answer. Cite the source you actually used.
4. Stop.

## Dummy

When the first word is `dummy`, strip that word and answer in everyday language. State the intent, then a simple description. Do not print commands, paths, or APIs. If a fact can only be said as a command, path, or API, say what the person is trying to accomplish and stop there. A later `dummy` inside the question stays part of the question.

## Do not

- Change files, settings, or product behavior.
- Emit a plan, a phase list, a rewritten prompt as the product, or a debug brief.
- Pretend another skill file was loaded.
