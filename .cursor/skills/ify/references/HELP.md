# Ify — user reference

Print this file as the response when the user runs `/ify help`,
`/ify --help`, or `/ify /?`. Do not plan, execute, debug, answer a
domain question, or dispatch a recommended verb.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), or `help pass`, print only the
**Pass (`Npass`)** section below and stop. There is no `/pass`
skill.

Empty `/ify` is the short usage cheat, not this page.
`help me …` is **not** a task and not this catalog — print short
usage plus `unknown verb; try /ify which …`.

---

## What it does

Promptify-family **front door**: catalog, help, and router. Does
**not** plan, execute, debug, or answer domain questions.

`which` **prints** a recommended invocation. It does **not**
dispatch. The user (or a later turn) runs that verb.

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
/ify tldr            — narrative-free tldr of ify
/ify tldr <verb>     — narrative-free tldr of that verb
/ify which <prompt>  — recommend verb + rewritten prompt (do not run)
/ify <prompt>        — implicit which
/ify pass help       — Pass (Npass) subsection (also `pass`)

Already know the verb? Run it directly. Append to last ify? /addify
```

The prompt for `which` (or implicit which) is everything after the
subcommand, or the free-text request when they said “ify this”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/ify` *(empty)* | Short usage | Catalog one-liner + syntax. Not Help, not Next. |
| `/ify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/ify help <verb>` | Extreme help | Full user-facing help for that verb (see `/ify help <verb>`) |
| `/ify tldr` / `tldr <verb>` | tldr | Narrative-free: one-line, syntax, args table, examples table |
| `/ify which <prompt>` | which | Recommend `<verb> <rewritten prompt>` + one short why. **Do not run it.** |
| `/ify <prompt>` | Implicit which | Same as `which` |
| `/ify pass` / `pass help` / `help pass` | **Pass help** | Print the Pass section; stop |
| `/ify help me …` / `help <unknown>` | Not a verb | Short usage + `unknown verb; try /ify which …` |

`--help` / `/?`: ify’s own catalog. Extra tokens are **ignored**
(not `help <verb>`). Word `help` with no second token: this page.

---

## Family catalog (this tree: Cursor)

| Verb | When to use | Alias |
|------|-------------|-------|
| **askify** | Question / list / options / explain existing (read-only answer) | `/promptify-ask` |
| **plannify** | Plan / design / phases (read-only plan; no implement) | `/promptify-plan`, `planify` |
| **runnify** | Implement / execute (not a named phase, not a bug) | `/promptify-run` |
| **phasify** | Next phase / named PN on the **current** plan | — |
| **debugify** | Bug / failing / root cause — **kickoff only** (paste into Cursor Debug Mode; does not instrument or fix) | `/promptify-debug` |
| **promptify** | Optimize the prompt only (no run, no plan, no answer) | — |
| **addify** | Append text to the last ify in this chat and restart/continue that skill | — |
| **ify** | Which verb / family help / tldr | — |

**Ify set:** `addify` · `askify` · `debugify` · `ify` · `phasify` ·
`plannify` · `promptify` · `runnify`.

---

## Not ify

These are **never** `<verb>` for `/ify help` / `/ify tldr`. Grok-only
utilities stay Not ify on both trees:

`/image` · `/imagine` · `/help` · `/create-skill` · `/check-work` ·
`/code-review` · `/debug-kickoff`

`/ify help image` → short usage + `unknown verb; try /ify which …`
plus `not an ify; use /image help`.

---

## Flags (`Nimages` / `Npass`)

Cite promptify **Flag parse order** — do not fork. Read left to
right. Each family independently. **First numbered instance** wins.

| Rule | Example |
|------|---------|
| Numbered instance counts | `1image`, `1 image`, `1-image`, `3images`, `2pass`, `2-pass` |
| Unnumbered word does **not** count | `image`, `images`, `pass`, `passes` — keep scanning |
| Several numbered → first only | Do **not** take the largest N |
| No numbered instance → flag absent | Ordinary English “image” / “pass” is not a marker |
| **`-2pass` is Npass** | Not a subcommand |

Strip **before** deciding Help vs usage vs `which`. Flags are not
subcommand text or `which` prompt wording. After strip:
`/ify 1image` is **empty usage** + 1 image;
`/ify 2pass help debugify` is **help debugify** + `2pass`.

Lead with the standard scratch / Npass acknowledgments when markers
are present (scratch first, then Npass). ify rarely needs images;
still honor the family contract.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` (or `help pass`) prints **this
section** and stops. Full family flag reference:
`/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**.

**Meaning:** N pipeline passes of **this ify mode’s** work (catalog
print, extreme help, tldr, or which). Not task wording. Not a
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

## Extreme help, tldr, and which (catalog)

These modes are part of `/ify`. This page is the **family catalog**
only. Do not invent a verb’s help text here. Extreme-help
concatenate: ify `SKILL.md`. tldr extract: `references/TLDR.md`.
which decide: `references/WHICH.md`.

| Mode | User-facing meaning |
|------|---------------------|
| `/ify help <verb>` | Extreme (full) help for a known ify verb or alias |
| `/ify tldr` / `tldr <verb>` | Narrative-free: one-line description, syntax, args table, examples table |
| `/ify which <prompt>` | Recommend `<verb> <rewritten prompt>` + one short why. Does **not** run it. |
| `/ify <prompt>` | Implicit which |

Frozen `which` example shape:

```text
/ify which "List all of the options for pytch ghl"
→ askify what are the command line options for ptych ghl?
```

---

## Hard rules (short)

- Catalog + help + router only. Never plan, execute, debug, or
  answer the user’s domain question.
- `which` (explicit or implicit) does **not** dispatch.
- Empty `/ify` is short usage, not Help, not Next.
- `help me …` / `help <unknown>` is not a task and not extreme help.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  stop. Exact `pass` / `pass help` / `help pass`: print **Pass
  (`Npass`)** only.
- Do not invent verbs. Known verbs are the Ify set above.

---

## Related

| Command | Role |
|---------|------|
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/plannify <prompt>` | Optimize then plan (read-only) |
| `/plannify fromhere` | Replan from current statuses |
| `/runnify <prompt>` | Optimize then execute |
| `/phasify` | Execute the next plan phase |
| `/promptify <prompt>` | Analyze / optimize only |
| `/debugify <bug>` | Debug Mode kickoff prompt (paste into Cursor Debug Mode) |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill |
