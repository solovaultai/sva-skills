---
name: plannify
description: >
  Plannify — write a plan on grok.com and end with a phase list.
  Does not implement the plan. Use only when the user invokes
  plannify.
---

# Plannify

Run this only when the user invokes plannify on grok.com. Do not load it on your own.

Write a plan. Do not implement it. The response ends with a phase list.

## What to do

1. Restate the goal, the constraints they named, and the assumptions you are making. If a choice would change the plan, pick the smaller option, name that assumption, and continue.
2. Write a short plan: ordered phases, what each one ships, and what is out of scope. Stay proportional to the request. Do not invent files, APIs, or systems they did not mention. Mark those as unknown.
3. End the response with the phase list. Nothing after that table.

## Phase list

The last thing you print is a real table, not an example buried in a fence:

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| P0 — Title | One line: what this phase ships | Not started |

One row per phase. Status on a new plan is `Not started`. Use `Deferred` only for a slice you are explicitly postponing, and put the reason in the description.

## Do not

- Edit, build, or apply the plan.
- Add instrumentation or a fix.
- Pretend another skill file was loaded.
