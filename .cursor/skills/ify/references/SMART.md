# Ify smart — verb decision + rewrite

Cite `docs/smart_contract.md`. `/ify smart <prompt>`, `/ify which
<prompt>` (`which` = reserved-token **alias** of `smart`), and
bare `/ify <prompt>` (implicit smart). **Print** the family
preamble. **Do not** dispatch or run the verb. After-select:
**Stop.** One short why is allowed here; forbidden on tldr.

`smart` / `which` with **no** prompt: ify’s short usage + say
smart needs a prompt. Do not invent a recommendation.

---

## Output shape (mandatory)

Family preamble (`docs/smart_contract.md`):

```text
**Smart — selected.**
`/<verb> <canonical invocation>`
<one-line why>
```

- `<verb>` is a canonical Ify-set name.
- `<canonical invocation>` is the user’s intent restated as that
  verb’s task. Not a plan. Not an answer.
- Why: one short sentence. No extra sections. No status table.

Frozen example (verbatim shape):

```text
/ify smart "List all of the options for pytch ghl"
→ **Smart — selected.**
  `/askify what are the command line options for ptych ghl?`
```

Why for that example: listing CLI options of an existing tool is
a read-only question → askify. Rewrite fixes `pytch` → `ptych`
(same token the user meant) and turns “list the options” into
“what are the command line options”.

`/ify which "List all of the options for pytch ghl"` is the same
example (`which` alias).

---

## Decision table (first matching row wins)

Read the prompt. Pick the **first** row that fits. Do not invent
verbs.

| If the prompt is mainly… | Verb |
|--------------------------|------|
| Which verb / family help / tldr / “what does ify do” | **ify** |
| Feature add / change on the **current plan** (last was plannify / phasify) | **plannify** as `add <feature>` |
| Append / “also” / “and also” aimed at the **last ify** in this chat | **addify** |
| Optimize / rewrite **the prompt only** (no run, no plan, no answer) | **promptify** |
| Bug / failing / broken / root cause / stack trace | **debugify** (this tree: Cursor kickoff only) |
| Next phase / named `PN` / `pN` / “run phase” on the **current** plan | **phasify** |
| Plan / design / phases / “how should we slice this” (no current-phase execute) | **plannify** |
| Instructions live in local files | **fromify** when no ify verb is named; if the user already named a verb, that verb with `from=` |
| Document this prompt | **docify**. Default is askify; a leading ify verb selects that verb |
| Implement / execute / build / “just do it” (not a named phase, not a bug) | **runnify** |
| Question / list / options / explain **existing** (read-only) | **askify** |

If nothing matches: **askify** (least mutable default for a
question-shaped leftover) unless the text is clearly “do the
work” → **runnify**.

---

## Ties (least mutable)

When two rows both fit, prefer the **least mutable** verb:

`askify` > `plannify` > `runnify`

Then the rest of the table order (ify / addify / promptify /
debugify / phasify / fromify / docify stay as matched). Examples:

- “What files exist and then add a flag” — question + implement:
  prefer **askify** for a list/explain ask; only **runnify** if
  they clearly want the change made now.
- “Design the API and implement it” — plan + implement: prefer
  **plannify** (plan first) over runnify.
- “Why does X fail and fix it” — explain + bug: **debugify**
  (bug row beats askify).
- “Run the next phase” on a current plan: **phasify**, not
  runnify.

---

## Rewrite rules

1. Lead with the chosen canonical verb.
2. Restate the user text as that verb’s task. Keep names, paths,
   and quoted tokens the user wrote.
3. Fix an obvious typo **only** when the intended token is clear
   from the same prompt (frozen: `pytch` → `ptych`). Do not invent
   a product or flag the user did not name.
4. Drop smart-meta (“which ify”, “what command should I use”).
5. Do **not** add `Nimages` / `Npass` unless the user already
   included a numbered flag token.
6. Do **not** run the verb. Do not print extreme help or tldr.

Verb-specific restatement (from that verb’s HELP / SKILL, not
invented):

| Verb | Rewrite toward |
|------|----------------|
| askify | a question to answer read-only |
| plannify | a planning request (plan, do not implement); current-plan feature add → `add <feature>` |
| runnify | the work to execute |
| phasify | the phase selector / next-phase request (no new plan) |
| debugify | the bug report (this tree: kickoff only) |
| promptify | the prompt to optimize (no execute) |
| addify | the text to append to the last ify |
| ify | `help`, `tldr`, or `smart <prompt>` — not a domain answer |
| fromify | file instructions as `from=` (defaults to plannify); a named verb keeps that verb with `from=` |
| docify | document this prompt; default askify; a leading ify verb selects that verb |

---

## Implicit smart

After flag strip, any non-empty body whose first token is not
`help` / `--help` / `/?` / `tldr` / `smart` / `which` / `pass` is
**implicit smart**. Same decision table, same preamble, same
no-dispatch rule.

`help me …` is **not** implicit smart (unknown-verb path).

---

## Hard rules

- Recommend only. Never dispatch. Cite `docs/smart_contract.md`.
- Never invent files, APIs, or verbs.
- Why is one line; tldr must not include why.
- This tree only for debugify (Cursor = kickoff).
- `which` is an ify-only alias of `smart`.
