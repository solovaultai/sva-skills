---
name: ify
description: >-
  Ify — catalog, help, and router for the Promptify family (plannify,
  runnify, promptify, phasify, debugify, askify, addify, ify). Does not
  plan, execute, debug, or answer domain questions. Use when the user
  runs /ify, "ify", /ify help, /ify help <verb>, /ify tldr, /ify tldr
  <verb>, /ify which, or wants to know which ify verb to use.
  `/ify which <prompt>` recommends a verb + rewritten prompt and does
  not dispatch. Bare `/ify <prompt>` is implicit which. Empty `/ify` is
  short usage, not Help and not Next. Print the family catalog with
  `/ify help` or `/ify --help` (also `/?`). `/ify pass help` (or `pass`)
  prints the Pass (`Npass`) section. Recognizes Nimages / N images /
  N-images as a pointer to the newest N images from the configured
  scratch source (or workspace scratch/). Recognizes Npass / N-pass /
  N pass as N pipeline passes of this mode's work. Flags work in all
  modes; strip before dispatch.
---

# Ify (= catalog + help + router)

You are running **Ify** (`/ify`) — the Promptify-family **front door**.
You do **not** plan, execute, debug, or answer domain questions.

| Situation | Command |
|-----------|---------|
| Already know the verb | `/askify`, `/plannify`, `/runnify`, … directly |
| Last turn was an ify; append text | `/addify …` |
| Don’t know which verb, or want family help/tldr | `/ify` |

`which` **prints** a recommended invocation. It does **not** dispatch.
The user (or a later turn) runs that verb.

Follow `~/.cursor/skills/promptify/SKILL.md` **Flag parse order**,
**Scratch images**, **Multi-pass**, and **Hard rules** (workspace is
source of truth; never invent files/APIs/tools/DBs). Do not fork a
different flag parse.

**This tree:** Cursor. `/debugify` here is Debug Mode **kickoff only**
(does not instrument/fix).

---

## Help (`help` / `--help` / `/?`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**. Extra tokens after `--help` / `/?` are ignored.
- Remaining body exactly `pass`, `pass help`, or `help pass`
  (case-insensitive): print the **Pass (`Npass`)** section of that
  file and **stop**. There is no `/pass` skill.

Do not plan, execute, debug, or answer. Empty `/ify` is the short
usage below, not Help. `help me …` is **not** a task.

## Landed deliverables

Parse, role, short usage, own-catalog Help, extreme help, tldr, and
which are frozen **here**.

| Deliverable | Lands |
|-------------|--------|
| `references/HELP.md` (family catalog + Pass subsection) | **P1 — landed** |
| Extreme-help concatenate; `references/TLDR.md` template | **P2 — landed** |
| `references/WHICH.md` decision table + rewrite rules | **P3 — landed** |
| addify Recover/dispatch + README | **P4 — landed** |
| Cross-tree check | **P5 — landed** |

---

## Flag parse order (`Nimages` / `Npass`)

Cite promptify **Flag parse order** — do not fork. Strip numbered
`Nimages` / `Npass` **first**, then dispatch. Flags are **not**
subcommand text or `which` prompt wording.

Read left to right. Each family independently. **First numbered
instance** wins.

- Numbered tokens count: `1image`, `2pass`, `2-pass`, `1images`,
  `N images`, `N-images` (also `Nimage` / `N-image` / `N pass`).
- Skip unnumbered `image` / `images` / `pass` / `passes`.
- Several numbered → first only (not the largest N).
- No numbered instance → that flag is absent.
- **`-2pass` is Npass**, not a subcommand.

Lead with the standard scratch / Npass acknowledgments when markers
are present (scratch first, then Npass). ify rarely needs images;
still honor the family contract.

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

```markdown
**Npass — caught and correctly interpreted.**
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan;
passes 2–N use that base for the final deliverable.
```

After strip: `/ify 1image` is **empty usage** + 1 image;
`/ify 2pass help debugify` is **help debugify** + `2pass`.

---

## Invocation (parse after stripping flags)

Case-insensitive. Optional leading `/` on a verb token is ignored
(`debugify` = `/debugify`). Match **reserved first tokens** before
treating the body as a prompt.

| After flag strip | Mode |
|------------------|------|
| *(empty)* | **Short usage.** Not Help, not Next. |
| `help` / `--help` / `/?` | ify’s own `references/HELP.md` (family catalog). |
| `help <verb>` | Extreme help for that verb. |
| `tldr` | Narrative-free tldr of **ify** itself. |
| `tldr <verb>` | Narrative-free tldr of that verb. |
| `which <prompt>` | Recommend verb + rewritten prompt. Do **not** run it. |
| `<prompt>` with no subcommand | **Implicit `which`**. |
| `pass` / `pass help` / `help pass` | ify’s Pass (`Npass`) subsection only. |
| `help me …` / `help <unknown>` | **Not a verb.** Short usage + unknown-verb line. |

**Unlike other ifys:** `help me …` is **not** a task. Do **not**
run implicit which on that leftover. Do **not** print a random
verb’s HELP.md.

### Disambiguation (required)

- Empty `/ify` is **short usage**, not Help, not Next (unlike
  `/phasify`).
- `--help` / `/?`: ify’s own HELP. Extra tokens are **ignored**
  (not `help <verb>`).
- Word `help` with **no** second token: ify’s own HELP.
- Word `help` + known verb / alias: **extreme help**.
- Word `help` + `pass` (remainder exactly `help pass`): **Pass
  help**. `pass` is **not** a verb.
- Word `help` + anything else (`me`, unknown, Not ify): **not a
  verb**. Short usage + `unknown verb; try /ify which …`. If the
  token is a **Not ify** utility, add `not an ify; use /<name> help`.
- Exact remaining body `pass` or `pass help`: **Pass help**. Extra
  tokens after `pass` that are not `help` are **not** Pass help —
  treat the whole remaining body as **implicit which**.
- `tldr` + known verb / alias: tldr of that verb. `tldr` alone:
  tldr of ify. `tldr` + unknown: same unknown-verb path as help.
- `which` with **no** prompt: short usage + say which needs a
  prompt. Do not invent a recommendation.
- Any other non-empty body (first token not `help` / `--help` /
  `/?` / `tldr` / `which` / `pass`): **implicit which**.

### Ify set (known verbs)

`addify` · `askify` · `debugify` · `ify` · `phasify` · `plannify`
· `promptify` · `runnify`

**Aliases → canonical** (help / tldr verb match)

| Alias | Canonical |
|-------|-----------|
| `promptify-plan`, `planify` | plannify |
| `promptify-run` | runnify |
| `promptify-ask` | askify |
| `promptify-debug` | debugify |
| `ify` | ify (own HELP / own tldr) |

**Not ify** (never a `<verb>`; Grok-only utilities stay Not ify):
`/image`, `/imagine`, `/help`, `/create-skill`, `/check-work`,
`/code-review`, `/debug-kickoff`.

`/ify help image` → unknown verb + `not an ify; use /image help`.

---

## Short usage (empty `/ify`)

Print this and **stop**. Not Help. Not Next.

```text
/ify                 — catalog + help + router (does not plan or execute)
/ify help            — family catalog (also --help, /?)
/ify help <verb>     — extreme help for that ify verb
/ify tldr            — narrative-free tldr of ify
/ify tldr <verb>     — narrative-free tldr of that verb
/ify which <prompt>  — recommend verb + rewritten prompt (do not run)
/ify <prompt>        — implicit which
/ify pass help       — Pass (Npass) subsection (also `pass`)

Already know the verb? Run it directly. Append to last ify? /addify
```

**Unknown verb / `help me …`:** print the same block, then:

```text
unknown verb; try /ify which …
```

---

## Extreme help (`help <verb>`)

This tree only. Resolve aliases first (table above). Then:

1. Banner (first line of the printed help):

```text
ify help — <canonical-verb> (this tree: cursor)
```

2. Print that verb’s **user-facing help in full**:
   `references/HELP.md` if that file exists in the verb’s folder
   (promptify, plannify, phasify, addify, runnify, askify,
   debugify, ify). Else the `## User help` section of that verb’s
   `SKILL.md`.
3. Then print the **rest** of that verb’s `SKILL.md` under a
   heading **Agent instructions**. Skip re-printing `## User help`
   if step 2 already printed it. Skip YAML frontmatter.
4. **Stop.** Do not invent, reconcile Cursor vs Grok, or add a
   status table.

`help ify` / alias `ify`: print ify’s own `references/HELP.md`
(same as `/ify help`), then this SKILL under **Agent
instructions**.

Unknown / Not ify: short usage + known-verb list (Ify set above)
+ `unknown verb; try /ify which …`. If the token is a listed Not
ify utility, also `not an ify; use /<name> help`.

## tldr (`tldr` / `tldr <verb>`)

Follow `references/TLDR.md` (template + extraction rules only).
Narrative-free: one-line description, syntax diagram, args table,
examples table. Omit rows not in the source. Do not invent flags.

- `tldr` alone: extract from ify’s `references/HELP.md`.
- `tldr <verb>`: resolve alias, extract from that verb (this tree).
- Unknown / Not ify: same path as extreme-help unknown.

## which (`which <prompt>` / implicit)

Follow `references/WHICH.md`. **Print** `<verb> <rewritten prompt>`
plus one short why. **Do not** dispatch.

- `which` with no prompt: short usage + say which needs a prompt.
- Bare `/ify <prompt>`: implicit which (same table).
- Frozen example: `/ify which "List all of the options for pytch ghl"`
  → `askify what are the command line options for ptych ghl?`

---

## Addify resume

**`ify` is an ify.** A last `/ify` in this conversation is a valid
last-ify. Addify (both trees) includes `ify` in the Ify set and
restarts `/ify` from scratch on the combined text. Skip empty /
help / tldr / pass when walking back; do **not** skip `which` or
bare-prompt-as-which.

---

## Hard rules

- Catalog + help + router only. Never plan, execute, debug, or
  answer the user’s domain question.
- `which` (explicit or implicit) does **not** dispatch.
- Strip `Nimages` / `Npass` first (promptify Flag parse order).
- Empty `/ify` is short usage, not Help, not Next.
- `help me …` / `help <unknown>` is not a task and not extreme help.
- Do not invent verbs, files, or APIs. Known verbs and Not ify
  lists above match `references/HELP.md`.
- Extreme help concatenates this tree’s sources only. tldr follows
  `references/TLDR.md` and does not invent flags.
- `which` follows `references/WHICH.md`. Recommend only; never
  dispatch.
- Keep this SKILL.md under 500 lines.
