# Ask

### Ask

Its own mode. Read-only. **No implementation.** **Do not**
change Status. Do **not** execute. Do **not** rewrite or
reprint the phased plan. Do **not** start `/plannify`. Do
**not** retitle (`docs/window_title.md`). Leave the window
on the phase the cycle was already on. The next empty
`/phasify` is still Next on that same plan.

Match `ask` before Named and before Next. The remainder
is the question. `ask` is not a phase selector. `ask p3`
is the question, not Named P3. `ask 3` is the question,
not Next-3.

| Text | Effect |
|------|--------|
| `ask <question>` | Answer the question about the current plan. Cite the phase ids the answer uses. Full enough to be useful. No new plan. No next-step menu. |
| `ask` (no question) | **Error:** `ask` needs a question. Do not execute. |

Locate the current plan the way `references/shared.md`
does (latest `## Phased plan`, or a resumeify `plan.md`).
Answer from that table, this conversation, and verified
files. **No plan:** say so. Do not invent phases. Do not
start `/plannify`.

Strip `Nimages` / `Npass` / `img=` first (promptify Flag
parse order and Named images). Read the N newest scratch
images, or the named files, and use them as evidence. No
new `images` word. Bare `images` does not count. If the
source or the images are missing, say so in the answer.
Do not invent pixels.

If `Npass` > 1: extra pass(es) improve this answer. Not a
whole-table replan. The last pass emits the answer.

Cite the phase ids the answer uses. Do not reprint the
table. No COMPLETED banners.

```text
/phasify ask what does P2 change
/phasify ask p3
/phasify ask 3
/phasify ask
```

`ask` with no question is **Error:** `ask` needs a question.
`ask p3` and `ask 3` are questions.
