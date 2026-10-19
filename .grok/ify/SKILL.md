---
name: ify
description: >
  Ify — catalog, help, and router for the Promptify family (plannify,
  runnify, promptify, phasify, debugify, askify, addify, fromify, docify, saveify, resumeify, optify, gitify, ify). Does not
  plan, execute, debug, or answer domain questions. Use when the user
  runs /ify, "ify", /ify help, /ify help <verb>, /ify tldr, /ify tldr
  <verb>, /ify smart, /ify which, or wants to know which ify verb to
  use. `/ify smart <prompt>` (alias `which`) recommends a verb +
  rewritten prompt and does not dispatch. Bare `/ify <prompt>` is
  implicit smart. Empty `/ify` is
  short usage, not Help and not Next. Print the family catalog with
  `/ify help` or `/ify --help` (also `/?`). `/ify tldr` prints ify’s
  short page; `/ify tldr <verb>` prints that verb’s. `/ify pass help`
  (or `pass`) prints the Pass (`Npass`) section. Recognizes Nimages / N images /
  N-images as a pointer to the newest N images from the configured
  scratch source (or workspace scratch/). Recognizes Npass / N-pass /
  N pass as N pipeline passes of this mode's work. Flags work in all
  modes; strip before dispatch.
metadata:
  short-description: "Catalog, help, and router for the ify family"
---

# Ify (= catalog + help + router)

You are running **Ify** (`/ify`) — the Promptify-family **front door**.
You do **not** plan, execute, debug, or answer domain questions.

| Situation | Command |
|-----------|---------|
| Already know the verb | `/askify`, `/plannify`, `/runnify`, … directly |
| Last turn was an ify; append text | `/addify …` |
| Don’t know which verb, or want family help/tldr | `/ify` |

`smart` **prints** a recommended invocation (family preamble in
`docs/smart_contract.md`). It does **not** dispatch. `which` is an
alias of `smart`. The user (or a later turn) runs that verb.

Follow `~/.grok/skills/promptify/SKILL.md` **Flag parse order**,
**Scratch images**, **Multi-pass**, and **Hard rules** (workspace is
source of truth; never invent files/APIs/tools/DBs). Do not fork a
different flag parse.

**This tree:** Grok. `/debugify` here is the **full** Debug Mode loop
(not Cursor’s kickoff-only debugify). `/debug-kickoff` is Not ify.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**. Extra tokens after `--help` / `/?` are ignored.
- Remaining body exactly `pass`, `pass help`, or `help pass`
  (case-insensitive): print the **Pass (`Npass`)** section of that
  file and **stop**. There is no `/pass` skill.
- Remaining body exactly `tldr` (case-insensitive): **read and
  print** `references/TLDR.md` (this skill folder) and **stop**.
  `tldr <verb>` is **tldr** below, not this bullet.

Do not plan, execute, debug, or answer. Empty `/ify` is the short
usage below, not Help. `help me …` is **not** a task.

## Landed deliverables

Parse, role, short usage, own-catalog Help, extreme help, tldr, and
smart are frozen **here**.

| Deliverable | Lands |
|-------------|--------|
| `references/HELP.md` (family catalog + Pass subsection) | **P1 — landed** |
| Extreme-help concatenate; printable `references/TLDR.md` | **P2 — landed** |
| `references/SMART.md` decision table + rewrite rules | **P3 — landed** |
| addify Recover/dispatch + README | **P4 — landed** |
| Cross-tree check | **P5 — landed** |

---

## Flag parse order (`Nimages` / `Npass`)

Cite promptify **Flag parse order** — do not fork. Strip numbered
`Nimages` / `Npass` **first**, then dispatch. Flags are **not**
subcommand text or `smart` prompt wording.

Read left to right. Each family independently. **First numbered
instance** wins.

- Numbered tokens count: `1image`, `2pass`, `2-pass`, `1images`,
  `N images`, `N-images` (also `Nimage` / `N-image` / `N pass`).
- Skip unnumbered `image` / `images` / `pass` / `passes`. Exception: the first typed token exactly `image` (any case) counts as `1image` and is stripped.
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

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` are
handed to the verb this router runs. Every token counts. Strip
them before the mode word.

## Invocation (parse after stripping flags)

Case-insensitive. Optional leading `/` on a verb token is ignored
(`debugify` = `/debugify`). Match **reserved first tokens** before
treating the body as a prompt.

| After flag strip | Mode |
|------------------|------|
| *(empty)* | **Short usage.** Not Help, not Next. |
| `help` / `--help` / `/?` | ify’s own `references/HELP.md` (family catalog). |
| `help <verb>` | Extreme help for that verb. |
| `tldr` | Print ify’s `references/TLDR.md`; stop. |
| `tldr <verb>` | Print that verb’s `references/TLDR.md` (this tree); stop. |
| `smart <prompt>` | Recommend verb + rewritten prompt. Do **not** run it. |
| `which <prompt>` | Alias of `smart`. |
| `<prompt>` with no subcommand | **Implicit `smart`**. |
| `pass` / `pass help` / `help pass` | ify’s Pass (`Npass`) subsection only. |
| `help me …` / `help <unknown>` | **Not a verb.** Short usage + unknown-verb line. |

**Unlike other ifys:** `help me …` is **not** a task. Do **not**
run implicit smart on that leftover. Do **not** print a random
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
  verb**. Short usage + `unknown verb; try /ify smart …`. If the
  token is a **Not ify** utility, add `not an ify; use /<name> help`.
- Exact remaining body `pass` or `pass help`: **Pass help**. Extra
  tokens after `pass` that are not `help` are **not** Pass help —
  treat the whole remaining body as **implicit smart**.
- `tldr` + known verb / alias: print that verb’s
  `references/TLDR.md` (this tree). `tldr` alone: print ify’s
  `references/TLDR.md`. `tldr` + unknown: same unknown-verb path
  as help.
- `smart` / `which` with **no** prompt: short usage + say smart
  needs a prompt. Do not invent a recommendation.
- Any other non-empty body (first token not `help` / `--help` /
  `/?` / `tldr` / `smart` / `which` / `pass`): **implicit smart**.

### Ify set (known verbs)

`addify` · `askify` · `debugify` · `docify` · `fromify` · `ify` · `phasify`
· `plannify` · `promptify` · `resumeify` · `runnify` · `saveify` · `optify` · `gitify`

**docify.** Document this prompt. Default is askify; a leading ify verb selects that verb. See `.grok/docify/SKILL.md`.

**optify.** Token policy, on by default. `/optify`, `/optify on`, `/optify off`, `/optify now`, `/optify before`, `/optify after`. The command is the same on Claude, Grok, Copilot, and Cursor. See `.grok/optify/SKILL.md`.

**gitify.** Add each dirty repo under the open folder, make one commit, then `git push origin <current-branch>`. A basename or component selects one repo. Empty `/gitify` is a real commit. Optional `tag`, `msg`, `link`, `forcemain`, and `all`. `dry-run` prints the action list and writes nothing. Stop words and any other unmatched token stop with no write. See `.grok/gitify/SKILL.md`.

**Aliases → canonical** (help / tldr verb match)

| Alias | Canonical |
|-------|-----------|
| `promptify-plan`, `planify`, `plify` | plannify |
| `promptify-run`, `runify` | runnify |
| `promptify-ask` | askify |
| `debug`, `dbgify`, `debify` | debugify |
| `phaseify`, `phify` | phasify |
| `prify` | promptify |
| `savify` | saveify |
| `resumify` | resumeify |
| `ify` | ify (own HELP / own tldr) |

**Not ify** (never a `<verb>`; Grok-only utilities stay Not ify):
`/image`, `/imagine`, `/help`, `/create-skill`, `/check-work`,
`/code-review`, `/debug-kickoff`.

`/ify help image` → unknown verb + `not an ify; use /image help`.

### Related (Grok utilities — not ify)

These are **not** help/tldr verbs. `/ify help <name>` is the
unknown-verb path, not extreme help.

- `/image`, `/imagine` — image tools
- `/help` — Grok product help (not ify catalog)
- `/create-skill`, `/check-work`, `/code-review`, `/debug-kickoff`

---

## Short usage (empty `/ify`)

Print this and **stop**. Not Help. Not Next.

```text
/ify                 — catalog + help + router (does not plan or execute)
/ify help            — family catalog (also --help, /?)
/ify help <verb>     — extreme help for that ify verb
/ify tldr            — short tldr of ify (stop)
/ify tldr <verb>     — short tldr of that verb (stop)
/ify smart <prompt>  — recommend verb + rewritten prompt (do not run)
/ify which <prompt>  — alias of smart
/ify <prompt>        — implicit smart
/ify pass help       — Pass (Npass) subsection (also `pass`)
/optify              — token policy, on by default (/optify on, /optify off, /optify now, /optify before, /optify after)
/gitify              — every dirty repo: commit, then push (empty is a real commit; optional forcemain or all)

Already know the verb? Run it directly. Append to last ify? /addify
```

**Unknown verb / `help me …`:** print the same block, then:

```text
unknown verb; try /ify smart …
```

---

## Extreme help (`help <verb>`)

This tree only. Resolve aliases first (table above). Then:

1. Banner (first line of the printed help):

```text
ify help — <canonical-verb> (this tree: grok)
```

2. Print that verb’s **user-facing help in full**:
   `references/HELP.md` if that file exists in the verb’s folder
   (promptify, plannify, phasify, addify, runnify, askify,
   debugify, docify, saveify, resumeify, optify, gitify, ify). Else the `## User help` section of that verb’s
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
+ `unknown verb; try /ify smart …`. If the token is a listed Not
ify utility, also `not an ify; use /<name> help`.

## tldr (`tldr` / `tldr <verb>`)

After flag strip (flags still ack first, then the page):

- Remaining body exactly `tldr` (case-insensitive): **read and
  print** `references/TLDR.md` (this skill folder) and **stop**.
- Remaining body `tldr <verb>`: resolve alias (table above), then
  **read and print** that verb’s `references/TLDR.md` in this
  tree and **stop**.
- Unknown / Not ify: same path as extreme-help unknown (short
  usage + `unknown verb; try /ify smart …`).

Do not extract a page from HELP. Do not invent flags or rows.

### Authoring notes (tldr files)

- This tree only. Do not read the other tree or reconcile Cursor
  vs Grok.
- Do not invent. Print the file as-is.
- `/ify tldr` prints ify’s `references/TLDR.md`. `/ify tldr
  <verb>` prints that verb’s `references/TLDR.md` (same bytes as
  `/<verb> tldr`).

## smart (`smart <prompt>` / `which` alias / implicit)

Cite `docs/smart_contract.md`. Follow `references/SMART.md`.
**Print** the family preamble. **Do not** dispatch.

- `smart` / `which` with no prompt: short usage + say smart needs
  a prompt.
- Bare `/ify <prompt>`: implicit smart (same table).
- Frozen example: `/ify smart "List all of the options for pytch ghl"`
  → `/askify what are the command line options for ptych ghl?`

---

## Addify resume

**`ify` is an ify.** A last `/ify` in this conversation is a valid
last-ify. Addify (both trees) includes `ify` in the Ify set and
restarts `/ify` from scratch on the combined text. Skip empty /
help / tldr / pass when walking back; do **not** skip `smart`,
`which`, or bare `/ify <prompt>`.

---

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `IFY:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

## Hard rules

- Catalog + help + router only. Never plan, execute, debug, or
  answer the user’s domain question.
- `smart` (explicit, `which` alias, or implicit) does **not** dispatch.
- Strip `Nimages` / `Npass` first (promptify Flag parse order).
- Empty `/ify` is short usage, not Help, not Next.
- `help me …` / `help <unknown>` is not a task and not extreme help.
- Do not invent verbs, files, or APIs. Known verbs and Not ify
  lists above match `references/HELP.md`.
- Extreme help concatenates this tree’s sources only. Exact `tldr`
  after flag strip prints `references/TLDR.md` and stops.
  `tldr <verb>` prints that verb’s `references/TLDR.md` (this
  tree). Do not invent tldr flags or rows.
- `smart` follows `docs/smart_contract.md` and `references/SMART.md`.
  Recommend only; never dispatch. `which` is an ify-only alias.
- Keep this SKILL.md under 500 lines.
