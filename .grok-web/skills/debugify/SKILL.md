---
name: debugify
description: >
  Debugify — debug kickoff on grok.com. States hypotheses and what
  to check. Does not instrument and does not fix. Use only when the
  user invokes debugify.
---

# Debugify

Run this only when the user invokes debugify on grok.com. Do not load it on your own.

This is kickoff only. State hypotheses and what to check. Do not instrument. Do not fix.

## What to do

1. From the report, fill in what you can: symptom, expected, actual, how to reproduce, and evidence they already gave. Mark the rest unknown. Do not invent stack traces, files, or logs.
2. Write 2–5 falsifiable hypotheses. Each one says what would support it and what would rule it out.
3. For each hypothesis, say what to check: which behavior, input, message, or comparison would decide it. Checking means inspect or compare. It does not mean add probes, logs, or code.
4. Stop.

## Do not

- Add instrumentation, temporary logs, or probes.
- Propose a patch or apply a fix.
- Edit anything.
- Pretend another skill file was loaded.
