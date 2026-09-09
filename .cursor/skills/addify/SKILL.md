---
name: addify
description: >-
  Addify — append text to the previous ify call and restart or continue
  that skill. Recovers the last ify in this conversation (promptify,
  plannify, phasify, runnify, debugify, askify, ify, or a prior addify),
  verbatim-appends the addify body, and dispatches to that skill.
  Use when the user runs /addify, "addify", "add this to the last ify",
  or "append this to the previous ify". Print a complete reference with
  `/addify help` or `/addify --help` (also `/?`). Empty `/addify` is
  short usage, not Next. Recognizes Nimages / N images / N-images as a
  pointer to the newest N images from the configured scratch source
  (or workspace scratch/). Recognizes Npass / N-pass / N pass as a
  pass-count flag that applies to the restarted skill (addify-line
  wins the same family).
---

# Addify (= append to last ify)

You are running **Addify** (`/addify`) — a **thin conversation router**
in the Promptify family. You do not optimize or plan by yourself.

1. Parse help / empty / flags.
2. Recover the last ify from **this conversation**.
3. Build a combined prompt (original body + addify body).
4. Print a short banner.
5. **Run the target skill** as that skill’s `SKILL.md` specifies.

Follow `~/.cursor/skills/promptify/SKILL.md` for **Flag parse order**,
**Scratch images**, **Multi-pass**, and **Hard rules** (workspace is
source of truth; never invent files/APIs/tools/DBs). Mutability is
**inherited** from the target skill.

---

## Help (`help` / `--help` / `/?`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of that file and **stop**.
  There is no `/pass` skill.

Do not recover or dispatch. Empty `/addify` is the short usage below,
not Help. `help me …` is a **task**, not Help.

If the user invokes the skill with no prompt body, explain:

```text
/addify <text>     — append <text> to the last ify and restart/continue that skill
/addify help       — full reference (also --help, /?)
/addify pass help  — Pass (Npass) subsection (also `pass`)
```

Empty `/addify` is **short usage**, not Next (unlike `/phasify`).

The text to append is everything after the command, or the free-text
request when they said “addify this” / “add this to the last ify”.

---

## Flag parse order (`Nimages` / `Npass`)

Same as promptify. Read the user text **left to right**. For the
**image** family and the **pass** family independently, use **only the
first instance that counts**.

- A **numbered** instance counts: `1image`, `1 image`, `1-image`,
  `2images`, `3pass`, `2-pass`, `2 pass`, …
- An **unnumbered** word does **not** count: `image`, `images`, `pass`,
  `passes`. Skip it and keep scanning.
- If the first hit is unnumbered and a later hit **is numbered**, use
  that numbered instance.
- If several numbered tokens appear, use only the **first** numbered
  one left to right. Do **not** take the largest N.
- If there is no numbered instance, the flag is **absent**.

Those flags **apply to the restarted skill** (scratch ack / Npass /
Flags row).

- If both the original line and the addify line set the **same**
  family, **addify-line wins**.
- If only one line sets a family, that value applies.
- Lead with the standard scratch / Npass acknowledgments when those
  markers are present on the addify line, or still apply from the
  original when addify omitted them. Acks first when markers are
  present (scratch first, then Npass).

Follow promptify **Scratch images** and **Multi-pass** for how the
restarted skill consumes the flags.

---

## Recover last ify

Scan **this conversation** **newest-first** for a user turn that
invokes an ify via slash, alias, or free-text (`"plannify this"`,
`"runnify this"`, …). There is **no** file, env, or CLI “last ify”
store. Chat only.

**Ify set:** `promptify` · `plannify` · `phasify` · `runnify` ·
`debugify` · `askify` · `ify` · `addify`.

**Aliases → canonical**

| Alias / wording | Canonical |
|-----------------|-----------|
| `/promptify-plan`, `planify fromhere` | plannify |
| `/promptify-run` | runnify |
| `/promptify-ask` | askify |
| `/promptify-debug` | debugify |

**Not ify** (do not treat as last ify): `/image`, `/imagine`, `/help`,
`/create-skill`, `/check-work`, `/code-review`, `/debug-kickoff`.

**Skip when walking back**

- Exact help (`help` / `--help` / `/?` after flag strip)
- Empty usage for skills whose empty is usage (not a task)
- `/ify` empty usage; `/ify help` / `help <verb>`; `/ify tldr` /
  `tldr <verb>`; `/ify pass` / `pass help`

**Do not skip** empty `/phasify` (that is **Next**).
**Do not skip** `/ify which` or bare `/ify <prompt>` (implicit
which).

**If last is addify:** keep walking to the last **non-addify** ancestor.
Combined body = ancestor body + every later addify body **in
chronological order** (each verbatim). Then dispatch on the ancestor
type.

**If none / not an ify:** stop. Tell the user there is no last ify in
this conversation and show short usage. Do not invent a target.

**If last ify body cannot be recovered:** stop. Say so. Do **not**
substitute Intent Analysis, Kickoff/Optimized Prompt, or `## Plan`
text (same rule as phasify Task recovery).

---

## Combined prompt

```text
<original last-ify body>
<addify body>
```

- Append the user’s addify text **verbatim**. Do not rewrite,
  summarize, or “improve” it.
- Insert one newline so the last original token and first addify
  token do not glue.
- Strip `Nimages` / `Npass` tokens from the **addify** portion after
  parse (they are flags, not task wording). Leave the original body
  as recovered (the restarted skill’s own flag strip still applies).

---

## Banner (before the target skill’s output)

```markdown
**Addify — last ify: <name>.**
Appending your text to the previous `<slash or alias>` body and dispatching to <skill> (<scratch|fromhere|mid-run|from scratch>).
```

Then the target skill’s **full** pipeline (including its trailing
table when that skill requires one).

---

## Dispatch

| Last ify | Action |
|----------|--------|
| **plannify** | Restart `/plannify` **from scratch** on the combined text. New Planning-Kickoff + new plan. **Not** fromhere. Discard old phase statuses. |
| **promptify** | Restart `/promptify` on the combined text (new optimize only; do not execute). **Not** fromhere. |
| **phasify** | Run **`/plannify fromhere` + new prompt**. Keep Done/Deferred/Def-Blocked (+ reasons). Task = original Task (verbatim ify wording) **plus** appended addify text. Same Flags plus addify-line flags (addify-line wins the same family). Then AskQuestion: Keep new plan vs Continue original. |
| **debugify** | Restart **this platform’s** debugify (Cursor: Debug Mode **kickoff only**) on combined bug text **plus prior-run learnings** (falsified/confirmed hypotheses, evidence, suspect paths already ruled out). New kickoff. Do not throw away evidence. |
| **runnify — planning** | No `## Results` and no mutating work started → re-runnify from scratch: optimize + execute on the combined prompt. |
| **runnify — mid-run** | Results and/or phase work started → **not** greenfield. Continue from current phase statuses with new knowledge + appended text (Done stays Done; resume Left / Unblocked / In progress / Blocked / Def-Blocked as the current table shows). |
| **addify** | Not a leaf. Resolve ancestor + concatenate addify texts; dispatch on the ancestor type. |
| **askify** | Restart `/askify` on combined text (new Ask-Kickoff + new answer). No fromhere exists. |
| **ify** | Restart `/ify` on the combined text **from scratch** (same shape as askify / promptify). **Not** fromhere. |

**fromhere + addify (phasify last):** same outcome as a user who ran
`/plannify fromhere` but whose Task is the old Task plus the new
sentence(s). If no current plan exists, say `/plannify` first
(fromhere rule) — do not invent phases.

Read the target skill from this tree (`~/.cursor/skills/<name>/SKILL.md`
or this repo’s `.cursor/skills/<name>/SKILL.md`) and follow it
completely after the banner.

---

## Hard rules

- Thin router only: banner + dispatch. Do not run a second promptify
  pipeline of your own.
- Never invent a last-ify store, target skill, or workspace resource.
- Recover from **this conversation** only. Newest-first. Skip
  help-only / empty-usage last ify except empty phasify = Next.
- If last is addify, walk to the last non-addify ancestor; combine
  ancestor + all addify bodies in chronological order.
- If none / body unrecoverable: stop + usage. Do **not** substitute
  Intent / Kickoff / Plan for the original body.
- Combined prompt = original body + newline + addify body
  (**verbatim**). Strip `Nimages` / `Npass` from the addify portion
  after parse.
- Flag parse order: first numbered instance per family; addify-line
  wins the same family. Acks first when markers are present.
- Dispatch per the table. plannify / promptify / **ify** restart
  from scratch (**not** fromhere). phasify = fromhere + AskQuestion.
  Cursor debugify = kickoff only. runnify planning = from scratch;
  mid-run = continue. askify = restart.
- Skip ify help / tldr / pass / empty usage when walking back. Do
  **not** skip ify `which` or bare-prompt-as-which.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `pass` / `pass help`: print
  the **Pass (`Npass`)** section and stop. Empty `/addify` is
  short usage, **not** Next. `help me …` is a task.
- Inherit mutability from the target. Last printed content is
  whatever the target skill requires (often its trailing phase table).
