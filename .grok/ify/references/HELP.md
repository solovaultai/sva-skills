# Ify — user reference

Print this file as the response when the user runs `/ify help`,
`/ify --help`, or `/ify /?`. `/ify tldr` prints the short
`references/TLDR.md` page (do not print this file). Do not plan,
execute, debug, answer a domain question, or dispatch a
recommended verb.

If the remaining body after flag strip is exactly `tldr`
(case-insensitive), print `references/TLDR.md` and stop. If it is
exactly `pass` or `pass help` (case-insensitive), or `help pass`,
print only the **Pass (`Npass`)** section below and stop. There
is no `/pass` skill.

Empty `/ify` is the short usage cheat, not this page.
`help me …` is **not** a task and not this catalog — print short
usage plus `unknown verb; try /ify smart …`.

---

## What it does

Promptify-family **front door**: catalog, help, and router. Does
**not** plan, execute, debug, or answer domain questions.

`smart` **prints** a recommended invocation (family preamble).
It does **not** dispatch. `which` is an alias of `smart`. The
user (or a later turn) runs that verb.

A real ify task sets the tmux window name so a row of Grok
windows can be told apart. The contract is `docs/window_title.md`.
Prefixes: `PLAN:`, `DBG:`, `RUN:`, `PROMPT:`, `ASK:`, `IFY:`, `FROM:`,
`DOC:`, `SAVE:`, `RESUME:`, `OPT:`, `GIT:`, `IMG:`.
Addify reuses the ancestor's prefix. Phasify is
`PHASE:P<n>/<total>:<PREFIX>: <summary>`. Help, tldr, pass, and
empty usage do not retitle.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write this verb's deliverable (see `the docify skill's references/docify_contract.md`). Not a verb.

---

## When to use vs addify vs a direct verb

| Situation | Command |
|-----------|---------|
| Already know the verb | `/askify`, `/plannify`, `/runnify`, … directly |
| Last turn was an ify; append text | `/addify …` |
| Don’t know which verb, or want family help / tldr | `/ify` |

`/ify` is not a substitute for `/addify`. If the last turn was an
ify and you have more text for that same run, use `/addify`.

---

## How to invoke

```text
/ify                 — catalog + help + router (does not plan or execute)
/ify help            — this family catalog (also --help, /?)
/ify help <verb>     — extreme help for that ify verb
/ify tldr            — short tldr of ify (stop)
/ify tldr <verb>     — short tldr of that verb (stop)
/ify smart <prompt>  — recommend verb + rewritten prompt (do not run)
/ify which <prompt>  — alias of smart
/ify <prompt>        — implicit smart
/ify pass help       — Pass (Npass) subsection (also `pass`)
/optify              — token policy, on by default (/optify on, /optify off, /optify now, /optify before, /optify after)
/gitify              — every dirty repo: commit, then push (empty is a real commit; optional forcemain, all, get, put, or unarchive)
/imagify             — text from the newest scratch image (empty is 1image; text, totext, 2text; embedded agent images win; aliases imgfy, imageify; copies the text)

Already know the verb? Run it directly. Append to last ify? /addify
```

The prompt for `smart` (or `which`, or implicit smart) is
everything after the subcommand, or the free-text request when
they said “ify this”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/ify` *(empty)* | Short usage | Catalog one-liner + syntax. Not Help, not Next. |
| `/ify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/ify help <verb>` | Extreme help | Full user-facing help for that verb (see `/ify help <verb>`) |
| `/ify tldr` / `tldr <verb>` | tldr | Print that verb’s `references/TLDR.md` (ify’s own file when no verb); stop |
| `/ify smart <prompt>` | smart | Recommend via family preamble. **Do not run it.** |
| `/ify which <prompt>` | smart (alias) | Same as `smart` |
| `/ify <prompt>` | Implicit smart | Same as `smart` |
| `/ify pass` / `pass help` / `help pass` | **Pass help** | Print the Pass section; stop |
| `/ify help me …` / `help <unknown>` | Not a verb | Short usage + `unknown verb; try /ify smart …` |

`--help` / `/?`: ify’s own catalog. Extra tokens are **ignored**
(not `help <verb>`). Word `help` with no second token: this page.

---

## Family catalog (this tree: Grok)

| Verb | When to use | Alias |
|------|-------------|-------|
| **askify** | Question / list / options / explain existing (read-only answer). `dummy` is a non-technical tell | `/promptify-ask` |
| **plannify** | Plan / design / phases (read-only plan; no implement) | `/promptify-plan`, `planify`, `plify` |
| **runnify** | Implement / execute (not a named phase, not a bug) | `/promptify-run`, `runify` |
| **phasify** | Next phase / named PN / **explain** / **dummy** / **tldr** phase tell / **guide** / **coach** / **runblock** / **howto** / **remove** (`delete` alias) on the **current** plan | `phaseify`, `phify` |
| **debugify** | Bug / failing / root cause — **full** Debug Mode loop (not Cursor’s kickoff-only debugify) | `/debug`, `dbgify`, `debify` |
| **promptify** | Optimize the prompt only (no run, no plan, no answer) | `prify` |
| **addify** | Append text to the last ify in this chat and restart/continue that skill | — |
| **fromify** | Splice local files into a prompt. Defaults to plannify; a named ify verb on the line selects that verb. | — |
| **docify** | Document this prompt. Default is askify; a leading ify verb selects that verb. See `.grok/docify/SKILL.md`. | — |
| **ify** | Which verb / family help / tldr | — |
| **saveify** | Save the current ify context (auto-name if unnamed). Delete by name or list number after yes/no. Empty `/saveify` is a real save. | `savify` |
| **resumeify** | List newest-first with dates. Restore by name or number so `/phasify` can continue. Empty `/resumeify` is a selection list. `Choose none` stops. A saved context restores. | `resumify` |
| **optify** | Token policy, on by default. `/optify`, `/optify on`, `/optify off`, `/optify now`, `/optify before`, `/optify after`. The command is the same on Claude, Grok, Copilot, and Cursor. See `.grok/optify/SKILL.md`. | — |
| **gitify** | Add each dirty repo under the open folder, make one commit, then `git push origin <current-branch>`. A basename or component selects one repo. Empty `/gitify` is a real commit. Optional `tag`, `msg`, `link`, `forcemain`, and `all`. `dry-run` prints the action list and writes nothing. `get <plug>` pulls or clones a literal basename prefix and skips archived and ignored repos. `put <plug>` checks existing repos in to `origin main`, or creates a missing repo with git-crypt. `unarchive <repo>` restores one archived repo. With no plug or name, and the open folder is a git repo, `get`, `put`, and `unarchive` act on that repo only. Stop words and any other unmatched token stop with no write. See `.grok/gitify/SKILL.md`. | — |
| **imagify** | Print only the text in the newest scratch image, or in N images. `<n>image`, `<n>images`, `image<n>`, and `images<n>` set N. Blank n and a line with no image directive are `1image`. `text`, `totext`, and `2text` select text mode, which is also the default. The reply is the transcribed text and nothing else. When the agent message has an embedded image, those images are the source on Cursor, Grok, Claude, and GitHub Copilot. The image directive does not change that. The transcribed text is copied to the clipboard. `imgfy` and `imageify` are aliases. See `.grok/imagify/SKILL.md`. | `imgfy`, `imageify` |

**Ify set:** `addify` · `askify` · `debugify` · `docify` · `fromify` · `ify` ·
`phasify` · `plannify` · `promptify` · `resumeify` · `runnify` · `saveify` · `optify` · `gitify` · `imagify`.

---

## Not ify

These are **never** `<verb>` for `/ify help` / `/ify tldr`:

`/image` · `/imagine` · `/help` · `/create-skill` · `/check-work` ·
`/code-review` · `/debug-kickoff`

`/ify help image` → short usage + `unknown verb; try /ify smart …`
plus `not an ify; use /image help`.

`/debug-kickoff` is Not ify (read-only debug brief). `/debug` is
an alias of `/debugify`, not a separate verb.

---

## Related (Grok utilities — not ify)

These are **not** help/tldr verbs. `/ify help <name>` is the
unknown-verb path, not extreme help.

| Command | Role |
|---------|------|
| `/image`, `/imagine` | Image tools (`/image` answers from scratch images; `/imagine` generates) |
| `/help` | Grok product help (not this ify catalog) |
| `/create-skill` | Scaffold a new Grok skill |
| `/check-work` | Verifier subagent on session work |
| `/code-review` | Maintainability audit |
| `/debug-kickoff` | Read-only debug brief (not `/debugify`) |

---

## Flags (`Nimages` / `Npass`)

Cite promptify **Flag parse order** — do not fork. Read left to
right. Each family independently. **First numbered instance** wins.

| Rule | Example |
|------|---------|
| Numbered instance counts | `1image`, `1 image`, `1-image`, `3images`, `2pass`, `2-pass` |
| Unnumbered word does **not** count | `image`, `images`, `pass`, `passes` — keep scanning |
| First typed token `image` counts as `1image` | Any case; stripped. Later numbered image token does not override |
| Several numbered → first only | Do **not** take the largest N |
| No numbered instance → flag absent | Ordinary English “image” / “pass” is not a marker |
| **`-2pass` is Npass** | Not a subcommand |

Strip **before** deciding Help vs usage vs `smart`. Flags are not
subcommand text or `smart` prompt wording. After strip:
`/ify 1image` is **empty usage** + 1 image;
`/ify 2pass help debugify` is **help debugify** + `2pass`.

Lead with the standard scratch / Npass acknowledgments when markers
are present (scratch first, then Npass). ify rarely needs images;
still honor the family contract.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
They are handed to the verb this router runs. Strip them before
the mode word.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` (or `help pass`) prints **this
section** and stops. Full family flag reference:
`/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**.

**Meaning:** N pipeline passes of **this ify mode’s** work (catalog
print, extreme help, tldr, or smart). Not task wording. Not a
phase selector. If N > 1, pass 1 is a documented pre-plan; the last
pass emits this mode’s deliverable. Acknowledge after the scratch
ack when both appear.

```text
/ify pass
/ify pass help
/ify help pass
/ify 2pass help
/promptify pass help
```

---

## Extreme help, tldr, and smart (catalog)

These modes are part of `/ify`. This page is the **family catalog**
only. Do not invent a verb’s help text here. Extreme-help
concatenate: ify `SKILL.md`. tldr prints that verb’s
`references/TLDR.md` (ify’s own file when no verb). smart decide:
`docs/smart_contract.md` + `references/SMART.md`.

| Mode | User-facing meaning |
|------|---------------------|
| `/ify help <verb>` | Extreme (full) help for a known ify verb or alias |
| `/ify tldr` / `tldr <verb>` | Print that verb’s `references/TLDR.md` (ify’s own file when no verb) |
| `/ify smart <prompt>` | Recommend via family preamble. Does **not** run it. |
| `/ify which <prompt>` | Alias of `smart` |
| `/ify <prompt>` | Implicit smart |

Frozen `smart` example shape:

```text
/ify smart "List all of the options for pytch ghl"
→ **Smart — selected.**
  `/askify what are the command line options for ptych ghl?`
```

---

## Hard rules (short)

- Catalog + help + router only. Never plan, execute, debug, or
  answer the user’s domain question.
- `smart` (explicit, `which` alias, or implicit) does **not** dispatch.
- Empty `/ify` is short usage, not Help, not Next.
- `help me …` / `help <unknown>` is not a task and not extreme help.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  stop. Exact `tldr`: print `references/TLDR.md`; stop. Exact
  `pass` / `pass help` / `help pass`: print **Pass (`Npass`)**
  only.
- Do not invent verbs. Known verbs are the Ify set above.
- Grok-only utilities stay **Not ify**.

---

## Related (Promptify family)

The Claude Code tree is `.claude/skills/`, installed to `~/.claude/skills/`.

| Command | Role |
|---------|------|
| `/askify <prompt>` | Answer only (read-only; no plan unless `/askify plan`) |
| `/askify dummy <prompt>` | Non-technical tell. No commands, paths, or APIs. Same kind of explanation as `/phasify dummy`. Not a phase selector (`dummy N` / `dummy pN` stay on phasify). `plan dummy` prints the kickoff plan first |
| `/plannify <prompt>` | Optimize then plan (read-only) |
| `/plannify fromhere` | Replan from current statuses |
| `/plannify add <feature>` | Surgical feature add on the just-run plan (last ify: plannify or phasify) |
| `/runnify <prompt>` | Optimize then execute |
| `/phasify` | Execute the next plan phase |
| `/phasify explain` | Full write-up of the next not-Done phase. Count selectors skip Done. Named `pN` may be Done (what landed; thin record quotes the description; do not invent work). Pending stays the full write-up. Blocked / Def-Blocked / partially blocked (`Progress` with a recorded blocker, same as howto): detailed steps from the record. Other statuses: no unblock list. Optional second word `guide`. No execute, no Status change, does not rewrite the plan. |
| `/phasify dummy` | Non-technical tell of the next not-Done phase. `dummy N` / `Ndummy` / `dummyN` = next N, not named PN. Named is only `dummy pN` and may be Done. `dummy 0` is Error (use `dummy p0`). On a block: spelled-out task names, not enough to perform. Other statuses: no unblock list. Optional second word `guide`. No execute, no Status change, does not rewrite the plan. |
| `/phasify tldr` | Exact `tldr` with no other token prints that verb’s `references/TLDR.md` and stops (never a phase id; `tldr help` is not help). Phase tell needs `tldr 1`, `tldr N`, `Ntldr`, `tldrN`, `tldr pN`, or `pN tldr`. `tldr N` = next N not-Done. Named `pN` may be Done. `tldr 0` is Error (use `tldr p0`). A leftover that is not a selector and not `guide` is still an explanation-only question. On a block: a numbered list a capable person could carry out. Other statuses: no unblock list. Optional second word `guide`. |
| `/phasify explain guide` | Only the second word on explain, tldr, or dummy (`explain guide`, `tldr guide p3`, `dummy guide`, `3explain guide`). Not runblock. Every target must be blocked or partially blocked, else Error and no file. User-guide depth, mermaid, web images/links/PDFs only when reuse is allowed. Writes through docify defaults, else `/home/ami/src/pytch/pytch-docs/agent/`, markdown, generated CAPS name (`GUIDE` if title empty). Does not commit. Missing pytch-docs is Error. Does not change Status. Does not reprint the plan. |
| `/phasify coach` | Matched before guide. `coach` / `coach 1` = next blocked or partially blocked phase. `coach pN` only if that phase is blocked or partially blocked. `coach 0` is Error (use `coach p0`). `coach N` for N≥2, `Ncoach`, `coachN` are Error (one phase). `coach guide` is Error. One instruction at a time; wait for questions and output, then the next step. Writes a `COACH_LOG` the same way as guide and prints the summary. Not runblock. Not howto. No Status change. |
| `/phasify runblock` | Unblock+run leftover work or mark `Done` (`runblock pN` / `runblockPN` / `PNrunblock` named; `runblock N` / `Nrunblock` / `2runblock` = next N blocked, not PN) |
| `/phasify howto` | Steps past the next blocked or partially blocked phase (`howto pN` named; `howto N` / `2howto` = next N, not PN). None: nothing to do, reprint the plan. |
| `/phasify remove` | Drop next not-Done phase after yes/no (`remove pN` / title named; `remove N` / `2remove` = next N, not PN). `delete` is an exact alias. |
| `/promptify <prompt>` | Analyze / optimize only |
| `/debugify <bug>` | Full Debug Mode loop |
| `/debug` | Alias of `/debugify` |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill |
| `/saveify` | Save the current ify context (auto-name if unnamed). Delete by name or # after yes/no. Empty `/saveify` is a real save. |
| `/resumeify` | List newest-first with dates. Restore by name or # so `/phasify` can continue. Empty `/resumeify` is a selection list. `Choose none` stops. A saved context restores. |
| `/optify` | Token policy, on by default. `/optify on`, `/optify off`, `/optify now`, `/optify before`, `/optify after`. The command is the same on Claude, Grok, Copilot, and Cursor. |
| `/gitify` | Add each dirty repo under the open folder, make one commit, then push that branch. A basename or component selects one. Optional tag, msg, link, `forcemain`, and `all`. `get` pulls or clones a literal prefix, `put` checks in to `origin main` or creates with git-crypt, and `unarchive` restores one archived repo. `dry-run` writes nothing. Empty `/gitify` is a real commit. Not a git engine. |
| `/imagify` | Print only the text in the newest scratch image, or in N images. `<n>image`, `<n>images`, `image<n>`, and `images<n>` set N. Blank n and no image directive are `1image`. `text`, `totext`, and `2text` are text mode, which is also the default. The reply is that text and nothing else. When the agent message has an embedded image, those images are the source on Cursor, Grok, Claude, and GitHub Copilot. The image directive does not change that. The transcribed text is copied to the clipboard. `imgfy` and `imageify` are aliases. |
