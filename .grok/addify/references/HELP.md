# Addify — user reference

Print this file as the response when the user runs `/addify help`,
`/addify --help`, or `/addify /?`. Do not recover or dispatch.
`/addify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/addify` is the short usage cheat, not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

A **thin conversation router**. Recovers the last ify in **this
chat**, verbatim-appends the addify body, and dispatches to that
skill. Does not optimize or plan by itself.

```text
/addify <text>     — append <text> to the last ify and restart/continue that skill
/addify help       — this reference (also --help / /?)
/addify tldr       — short form; stop
/addify pass       — Pass (Npass) subsection only (also pass help)
```

Empty `/addify` is **short usage**, not Next (unlike `/phasify`).

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `the docify skill's references/docify_contract.md`). Help, tldr, and pass do not write.

Addify has no window prefix of its own. It re-applies the ancestor
verb's label (see `docs/window_title.md`). Help, tldr, and pass do not
retitle.

---

## How to invoke

```text
/addify also handle empty folders
/addify 1image check the screenshot too
/addify help
/addify tldr
/addify pass help
```

The text to append is everything after the command, or the free-text
when they said “addify this” / “add this to the last ify”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/addify <text>` | **Append + dispatch** | Recover last ify; combine; run that skill |
| `/addify` *(empty)* | Short usage | No recover, no dispatch |
| `/addify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/addify tldr` | **tldr** | Print the short page; stop |
| `/addify pass` / `pass help` | **Pass help** | Print the Pass section; stop |

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me write a login form` is a
task (append that text).

---

## Last-ify recovery

Scan **this conversation** newest-first. Chat only — no disk store.

**Ify set:** `promptify` · `plannify` · `phasify` · `runnify` ·
`debugify` · `askify` · `ify` · `addify` · `fromify` · `docify` ·
`saveify` · `resumeify` · `imagify`.

**docify.** Document this prompt. Default is askify; a leading ify verb selects that verb. See `.grok/docify/SKILL.md`.

**Aliases:** `/promptify-plan` / `planify` / `planify fromhere` / `plify` → plannify;
`/promptify-run` / `runify` → runnify; `/promptify-ask` → askify;
`/debug` / `dbgify` / `debify` → debugify; `phaseify` / `phify` → phasify;
`prify` → promptify; `savify` → saveify; `resumify` → resumeify.

**Skip:** help-only turns; exact `tldr` on any ify verb (same as
help); empty-usage turns (not a task);
`/ify` empty; `/ify help` / `help <verb>`; `/ify tldr` /
`tldr <verb>`; `/ify pass`; `/saveify` and `/resumeify` (not a
task), same as help / tldr. **Do not skip** empty `/phasify`
(that is Next). **Do not skip** `/ify smart`, `/ify which`,
or bare `/ify <prompt>` (implicit smart).

**Resume banner.** If this conversation's newest ify context is a
resumeify restore banner, the last ify is the saved verb named in
that banner, and the Task is the reprinted Task. Do not restart
saveify or resumeify as if they were plannify. Cite
`docs/saveify_contract.md`.

**If last is addify:** walk back to the last non-addify ancestor.
Combined body = ancestor + every later addify body in order.

**If none / body unrecoverable:** stop and show short usage. Do
**not** substitute Intent Analysis, Kickoff, or `## Plan` text.

Not ify: `/image`, `/imagine`, `/help`, `/create-skill`,
`/check-work`, `/code-review`, `/debug-kickoff`.

---

## Combined prompt

```text
<original last-ify body>
<addify body>
```

Append **verbatim**. One newline so tokens do not glue. Strip
`Nimages` / `Npass` from the **addify** portion after parse.

---

## Dispatch

| Last ify | Action |
|----------|--------|
| **plannify** / **promptify** | Restart that skill from scratch on the combined text. **Not** fromhere. Surgical plan feature add is `/plannify add`. |
| **phasify** | `/plannify fromhere` + new prompt. Keep Done/Deferred/Def-Blocked. Task = old Task + append. AskQuestion: Keep vs Continue. |
| **debugify** | Restart this platform’s debugify (Grok: **full loop**; alias `/debug`) + prior-run learnings. |
| **runnify — planning** | No Results / no mutating work → re-runnify from scratch. |
| **runnify — mid-run** | Continue from current phase statuses + new text (not greenfield). |
| **askify** | Restart askify on the combined text. |
| **ify** | Restart `/ify` from scratch on the combined text. **Not** fromhere. |
| **fromify** | Restart `/fromify` on the original invocation plus the appended text. Flags re-parse. Default verb remains plannify unless a verb token is present. |
| **docify** | Restart `/docify` on the original invocation plus the appended text. Flags re-parse. Default verb remains askify unless a verb token is present. |
| **imagify** | Restart `/imagify` on the combined text. The reply is still only the transcribed text. |
| **addify** | Resolve ancestor, then dispatch. |

If phasify is last and no current plan exists, say `/plannify` first.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right; skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`). Strip **before** deciding
Help vs task. Cite promptify **Flag parse order** — do not fork.

Flags on the addify line apply to the restarted skill. **Addify-line
wins** the same family. If only one line sets a family, that value
applies. Lead with the scratch / Npass acknowledgments when markers
are present.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
On this line they are flags for the restarted verb. Strip them
from the added text and hand them through. Do not drop them.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this section** and stops.
Full reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**.

**Meaning:** flags apply to the **restarted** skill (addify-line
wins the same family). If N > 1 on the restarted skill, pass 1 is
a documented pre-plan; the last pass emits that skill’s
deliverable. Acknowledge after the scratch ack when both appear.

```text
/addify pass
/addify pass help
/addify 2pass also handle empty folders
/promptify pass help
```

---

## Banner then target pipeline

```markdown
**Addify — last ify: <name>.**
Appending your text to the previous `<slash or alias>` body and dispatching to <skill> (<scratch|fromhere|mid-run|from scratch>).
```

Then the target skill’s full response (including its trailing table
when that skill requires one).

---

## Hard rules (short)

- Thin router: recover, append verbatim, dispatch. No second pipeline
  of your own.
- Conversation only. No last-ify file or CLI store.
- Skip help-only / empty-usage last ify except empty phasify = Next.
  Skip exact `tldr` on any ify verb (same as help). Also skip ify
  help / tldr / pass / empty; do **not** skip ify
  `smart`, `which`, or bare `/ify <prompt>`.
- Do not substitute Intent / Kickoff / Plan for the original body.
- Addify-line flags win the same family. Acks first when present.
- Empty `/addify` is short usage, **not** Next.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  stop. Exact `tldr`: print `references/TLDR.md` (not this file).
  Exact `pass` / `pass help`: print **Pass (`Npass`)** only.
  There is no `/pass` skill.

---

## Related

| Command | Role |
|---------|------|
| `/plannify <prompt>` | Optimize then plan (read-only) |
| `/plannify fromhere` | Replan from current statuses |
| `/plannify add <feature>` | Surgical feature add (keep unaffected phases). Prefer this over addify-on-plannify when you only want a feature added. |
| `/phasify` | Execute the next plan phase |
| `/runnify <prompt>` | Optimize then execute |
| `/promptify <prompt>` | Analyze / optimize only |
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/debugify <bug>` | Full Debug Mode loop |
| `/debug` | Alias of `/debugify` |
| `/debug-kickoff <bug>` | Read-only debug brief |
| `/ify` | Family catalog + help + router (`smart` recommends; `which` alias; does not dispatch) |
