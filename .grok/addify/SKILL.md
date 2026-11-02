---
name: addify
description: >
  Addify — append text to the previous ify call and restart or continue
  that skill. Recovers the last ify in this conversation (promptify,
  plannify, phasify, runnify, debugify, askify, ify, fromify, docify, or a prior addify),
  verbatim-appends the addify body, and dispatches to that skill.
  Use when the user runs /addify, "addify", "add this to the last ify",
  or "append this to the previous ify". Print a complete reference with
  `/addify help` or `/addify --help` (also `/?`). `/addify tldr`
  prints the short page. Empty `/addify` is
  short usage, not Next. Strips every numbered image directive for
  the restarted skill, including negatives, multiples, and zero
  (0image, image0, -0image). Does not open scratch and does not
  print the imagify zero error. Npass stays the first numbered
  instance and applies to the restarted skill (addify-line wins
  the same family).
metadata:
  short-description: "Append text to the last ify and restart/continue"
---

# Addify (= append to last ify)

You are running **Addify** (`/addify`) — a **thin conversation router**
in the Promptify family. You do not optimize or plan by yourself.

1. Parse help / empty / flags.
2. Recover the last ify from **this conversation**.
3. Build a combined prompt (original body + addify body).
4. Print a short banner.
5. **Run the target skill** as that skill’s `SKILL.md` specifies.

Follow `~/.grok/skills/promptify/SKILL.md` for **Flag parse order**,
**Scratch images**, **Multi-pass**, and **Hard rules** (workspace is
source of truth; never invent files/APIs/tools/DBs). Mutability is
**inherited** from the target skill.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `tldr` (case-insensitive):
  **read and print** `references/TLDR.md` (this skill folder) and
  **stop**. Extra tokens after `tldr` stay a **task**. There is
  no `tldr help` alias.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of that file and **stop**.
  There is no `/pass` skill.

Do not recover or dispatch. Empty `/addify` is the short usage below,
not Help. `help me …` is a **task**, not Help.

If the user invokes the skill with no prompt body, explain:

```text
/addify <text>     — append <text> to the last ify and restart/continue that skill
/addify help       — full reference (also --help, /?)
/addify tldr       — short form (stop)
/addify pass help  — Pass (Npass) subsection (also `pass`)
```

Empty `/addify` is **short usage**, not Next (unlike `/phasify`).

The text to append is everything after the command, or the free-text
request when they said “addify this” / “add this to the last ify”.

---

## Flag parse order (`Nimages` / `Npass`)

Read the typed line **left to right**. File bodies are not scanned.
Addify does not open scratch.

**Image family.** Strip every numbered image directive on the
typed line. `1image -3image` strips both. A negative count is
one directive.

Accepted shapes (case-insensitive). N is digits, including 0:

- `Nimage`, `Nimages`, `N-image`, `N-images`, `N image`, `N images`
- `imageN`, `imagesN`
- `-Nimage`, `-Nimages`, `-N-image`, `-N-images`, `-N image`, `-N images`
- `image-N`, `images-N`

`0image`, `image0`, and `-0image` are in that list, and so is every
other accepted shape whose digits are 0. Strip them. Do not print
`Error: image count starts at 1`.

`image -3` is not a negative directive. When that `image` is the
first token, it is `1image` and the `-3` stays on the line. Use
`-3image` or `image-3` for a negative. `image -3image` is two
directives when `image` is the first token (`1image` and `-3image`).
Both are stripped. Unnumbered `image` / `images` are not directives
except that leading `image`. `images` and a non-leading `image` stay
unnumbered.

**Pass family.** The first numbered `Npass`, `N-pass`, or `N pass`
is the pass flag. A later numbered pass token stays on the line.
Do not take the largest N. Unnumbered `pass` / `passes` are not
pass flags.

Every stripped image directive on the winning line applies to the
restarted skill. The pass value is that first numbered instance.
When the addify line has any image directive, that set replaces
image directives from the original line. When it has none, the
original line keeps its image directives. When the addify line has
a numbered pass, that pass replaces the original pass. When only
one line sets a family, that line applies. Lead with the standard
scratch / Npass acknowledgments when those markers are present on
the addify line, or still apply from the original when addify
omitted them. Acks first when markers are present (scratch first,
then Npass). Addify does not open the images.

Follow promptify **Scratch images** and **Multi-pass** for how the
restarted skill consumes the flags.

---

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` on this
line are flags for the restarted verb. Every token counts. Strip
them from the added text and hand them through. Do not drop them.

## Recover last ify

Scan **this conversation** **newest-first** for a user turn that
invokes an ify via slash, alias, or free-text (`"plannify this"`,
`"runnify this"`, …). There is **no** file, env, or CLI “last ify”
store. Chat only.

**Ify set:** `promptify` · `plannify` · `phasify` · `runnify` ·
`debugify` · `askify` · `ify` · `addify` · `fromify` · `docify` ·
`saveify` · `resumeify` · `imagify` · `buildify`.

**docify.** Document this prompt. Default is askify; a leading ify verb selects that verb. See `.grok/docify/SKILL.md`.

**Aliases → canonical**

| Alias / wording | Canonical |
|-----------------|-----------|
| `/promptify-plan`, `planify`, `planify fromhere`, `plify` | plannify |
| `/promptify-run`, `runify` | runnify |
| `/promptify-ask` | askify |
| `/debug`, `dbgify`, `debify` | debugify |
| `phaseify`, `phify` | phasify |
| `prify` | promptify |
| `savify` | saveify |
| `resumify` | resumeify |
| `imgfy`, `imageify` | imagify |

**Not ify** (do not treat as last ify): `/image`, `/imagine`, `/help`,
`/create-skill`, `/check-work`, `/code-review`, `/debug-kickoff`.

**Skip when walking back**

- Exact help (`help` / `--help` / `/?` after flag strip)
- Exact `tldr` after flag strip on **any** ify verb (same as help)
- Empty usage for skills whose empty is usage (not a task)
- `/ify` empty usage; `/ify help` / `help <verb>`; `/ify tldr` /
  `tldr <verb>`; `/ify pass` / `pass help`
- `/saveify` and `/resumeify` (not a task), same as help / tldr

**Do not skip** empty `/phasify` (that is **Next**).
**Do not skip** `/ify smart`, `/ify which`, or bare
`/ify <prompt>` (implicit smart).

**Resume banner.** If this conversation's newest ify context is a
resumeify restore banner, the last ify is the saved verb named in
that banner, and the Task is the reprinted Task. Do not restart
saveify or resumeify as if they were plannify. Cite
`docs/saveify_contract.md`.

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
| **plannify** | Restart `/plannify` **from scratch** on the combined text. New Planning-Kickoff + new plan. **Not** fromhere. Discard old phase statuses. Surgical feature add (keep unaffected phases) is **`/plannify add`**, not this path. |
| **promptify** | Restart `/promptify` on the combined text (new optimize only; do not execute). **Not** fromhere. |
| **phasify** | Run **`/plannify fromhere` + new prompt**. Keep Done/Deferred/Def-Blocked (+ reasons). Task = original Task (verbatim ify wording) **plus** appended addify text. Same Flags plus addify-line flags (addify-line wins the same family). Then AskQuestion: Keep new plan vs Continue original. |
| **debugify** | Restart **this platform’s** debugify (Grok: **full Debug Mode loop**) on combined bug text **plus prior-run learnings** (falsified/confirmed hypotheses, evidence, suspect paths already ruled out). Restart the loop; do not throw away evidence. Alias `/debug` maps here. |
| **runnify — planning** | No `## Results` and no mutating work started → re-runnify from scratch: optimize + execute on the combined prompt. |
| **runnify — mid-run** | Results and/or phase work started → **not** greenfield. Continue from current phase statuses with new knowledge + appended text (Done stays Done; resume Left / Unblocked / In progress / Blocked / Def-Blocked as the current table shows). |
| **addify** | Not a leaf. Resolve ancestor + concatenate addify texts; dispatch on the ancestor type. |
| **askify** | Restart `/askify` on combined text (new Ask-Kickoff + new answer). No fromhere exists. |
| **ify** | Restart `/ify` on the combined text **from scratch** (same shape as askify / promptify). **Not** fromhere. |
| **fromify** | Restart `/fromify` on the original invocation plus the appended text. Flags re-parse. Default verb remains plannify unless a verb token is present. |
| **docify** | Restart `/docify` on the original invocation plus the appended text. Flags re-parse. Default verb remains askify unless a verb token is present. |
| **imagify** | Restart `/imagify` on the combined text. The reply is still only that output (transcribed text, shown images, or the details listing). |
| **buildify** | Restart `/buildify` on the combined text. Create, ensure, or clone, then hand any instruction tail to runnify. `destroy` deletes only after the typed checks and does not hand a tail to runnify. |

**fromhere + addify (phasify last):** same outcome as a user who ran
`/plannify fromhere` but whose Task is the old Task plus the new
sentence(s). If no current plan exists, say `/plannify` first
(fromhere rule) — do not invent phases.

Read the target skill from this tree (`~/.grok/skills/<name>/SKILL.md`
or this repo’s `.grok/<name>/SKILL.md`) and follow it completely after
the banner.

---

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. This verb has no prefix of its own.
Re-apply the ancestor verb's label to the combined text on a real task.
Help, tldr, pass, and empty usage do not retitle.

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
- Flag parse order: strip every numbered image directive, including
  negatives and zero; pass stays the first numbered instance.
  Addify-line wins that family. Do not open scratch. Acks first when
  markers are present.
- Dispatch per the table. plannify / promptify / **ify** restart
  from scratch (**not** fromhere). phasify = fromhere + AskQuestion.
  Grok debugify = full loop (alias `/debug`). runnify planning =
  from scratch; mid-run = continue. askify = restart.
- Skip ify help / tldr / pass / empty usage when walking back. Skip
  exact `tldr` on **any** ify verb (same as help). Do **not** skip
  `/ify smart`, `/ify which`, or bare `/ify <prompt>`.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr` after flag strip:
  print `references/TLDR.md` and stop. Exact `pass` / `pass help`:
  print the **Pass (`Npass`)** section and stop. Empty `/addify` is
  short usage, **not** Next. `help me …` is a task.
- Inherit mutability from the target. Last printed content is
  whatever the target skill requires (often its trailing phase table).
