# Saveify — user reference

Print this file as the response when the user runs `/saveify help`,
`/saveify --help`, or `/saveify /?`. Also when the first token after
flag strip is `help`, `--help`, or `/?` (`help me …` included). Do
not write and do not delete. `/saveify tldr` prints the short page
(`references/TLDR.md`), not this file.

If the first token after flag strip is `pass`, including `pass help`,
print only the **Pass (`Npass`)** section below and stop. There is
no `/pass` skill.

Empty `/saveify` is a real auto-name save, not this page and not
short usage.

---

## What it does

A **thin snapshot verb**. Writes the current ify context to a
snapshot on this machine, or deletes one after yes/no. Does not
plan, execute, debug, answer, or restore. `/resumeify` lists and
restores. There is no `smart` mode.

Store path, snapshot files, `meta.json`, slug, auto-name, list
order, and confirm text: `docs/saveify_contract.md`. This page does
not restate that layout.

`savify` is a trigger word, not a command and not a folder.
Canonical slash is `/saveify`.

```text
/saveify                 — auto-name save
/saveify <name>          — save under that name
/saveify delete          — list, pick, then yes/no
/saveify delete <name>   — that row, then yes/no
/saveify delete <#>      — that position, then yes/no
/saveify help            — this reference (also --help / /?)
/saveify tldr            — short form; stop
/saveify pass            — Pass (Npass) subsection only (also pass help)
```

Empty `/saveify` is an **auto-name save**. It sets the window title.
Same exception shape as empty `/phasify` = Next.

No task and no phase table: **Error:** nothing to save. No directory
is written.

---

## How to invoke

```text
/saveify
/saveify testme
/saveify delete
/saveify delete testme
/saveify delete 2
/saveify help
/saveify tldr
/saveify pass help
```

`/saveify testme` saves under that name. If that snapshot already
exists, you get a yes/no question. The replace happens on the next
reply.

`/saveify 2` stores the name `2`. `/saveify delete 2` is list
position 2 (1 is the newest), not the name `2`.

The name is everything after `/saveify` once flags and modes are
taken off. A free-text “save the ify context” is this verb too.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/saveify` *(empty)* | **Auto-name save** | Real save. Not short usage. Sets `SAVE:` |
| `/saveify <name>` | **Named save** | Write that snapshot. Existing name asks yes/no first |
| `/saveify delete` | **Delete** | Print the list. You pick. Then yes/no |
| `/saveify delete <name>` | **Delete** | Show that row. Yes/no |
| `/saveify delete <#>` | **Delete** | Show that position. Yes/no |
| `/saveify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/saveify tldr` | **tldr** | Print the short page; stop |
| `/saveify pass` / `pass help` | **Pass help** | Print the Pass section; stop |

After flag strip, the first whole token selects the mode when it is
`delete`, `help`, `tldr`, `pass`, `--help`, or `/?` (case-insensitive).
`pass help` is pass. Those lines do not save and do not retitle.
`password` and `helpful` are names.

`/saveify delete help` deletes a snapshot named `help` (after
yes/no). It does not print this page.

---

## Names

A named save uses the remainder of the line. Auto-name runs only
when `/saveify` has no name. A taken auto-name slug becomes `-2`,
then `-3`. A named save of an existing slug asks to replace. It
does not append `-2`.

A name that slugs to empty: **Error:** name is empty. Nothing is
written.

The list is newest first. `#` is the position when the list was
printed. It is not a permanent id.

---

## Delete and replace

Every delete asks yes/no. Nothing is deleted on the line that
proposed it. Same-line `yes` does not apply. You see the row or the
set first.

Bare `/saveify delete`:

1. The numbered list. Stop.
2. You pick names or numbers. That set is shown. Yes/no. Stop.
3. The delete runs only after yes. One yes covers the set.

```text
**Saveify — confirm replace.**
`<display_name>` already exists (`<absolute snapshot dir>`).
Saved <saved_at>. Verb `<verb>`. Stage: <stage>.

Replace this snapshot? (yes/no)
```

```text
**Saveify — confirm delete.**
- <n>  <saved_at>  <display_name>  <verb>  <stage>  <cwd>

Delete this snapshot? (yes/no)
```

For a set, the question is `Delete these snapshot(s)? (yes/no)`.

| Reply | Effect |
|-------|--------|
| `yes` / `y` / `ok` / `confirm` | Apply |
| `no` / `n` / `cancel` / `abort` | Cancel. Store unchanged |
| A later command that is not yes/no | Cancel, then run that command |
| Any other reply | Ask again. Store unchanged |

`/saveify yes` and `/saveify no` answer a pending confirm. A yes/no
with no slash does too.

After yes, the reply is `**Saveify — replaced.**` or
`**Saveify — deleted.**` and the path or the rows. After no:
`**Saveify — cancelled.**`

If a `#` points at a different snapshot by the time you confirm,
nothing is deleted. **Error:** list changed. A replace whose
`saved_at` changed does not replace. Same error.

---

## What is saved

Saved: the recoverable ify artifacts this chat already printed
(task, phase table, plan, kickoff, or notes the contract names),
plus the metadata the contract lists.

Not saved: the raw transcript, unprinted reasoning, hidden model
state, a copy on another machine, an sshub sync. Nothing is saved
on exit.

No ify context (no task and no phase table): **Error:** nothing to
save.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right on the **typed line only**. Cite promptify **Flag parse
order** — do not fork. Strip **before** the mode or the name.

A stripped flag is not part of the snapshot name. Saveify does not
take N passes and does not open scratch. `/saveify 2pass` is an
auto-name save. `/saveify 2pass testme` saves the name `testme`.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, first token `pass`
(including `pass help`) prints **this section** and stops. Full
reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** the flag is stripped before the name. Saveify does not
loop. One save. The snapshot records the in-flight pass (k of N)
per `docs/saveify_contract.md`. When that Flags row is absent, k
is 1 and N is 1.

```text
/saveify pass
/saveify pass help
/saveify 2pass
/saveify 2pass testme
/promptify pass help
```

---

## Window title

Cite `docs/window_title.md`. Prefix: `SAVE:`. A save, including
empty `/saveify`, sets it. The summary is three to six words of the
task, or the display name when the task has no usable words.

Help, tldr, pass, delete, `--help`, and `/?` leave the current
name.

---

## Hard rules (short)

- Thin snapshot verb. Layout is `docs/saveify_contract.md`. No
  second store format. No `smart` mode. `/resumeify` restores.
- Empty `/saveify` is an auto-name save, not short usage.
- An existing name asks yes/no before replace. Auto-name does not
  overwrite.
- Every delete asks yes/no. Bare delete lists, you pick, then
  yes/no. Nothing is deleted on the proposing line.
- A later command that is not yes/no cancels. A `#` that moved is
  **Error:** list changed.
- No ify context: **Error:** nothing to save.
- Help, tldr, and pass print their page and stop. `savify` is not
  a command.
- Flags follow promptify Flag parse order. Saveify does not loop.

---

## Related

| Command | Role |
|---------|------|
| `/resumeify` | List or restore a snapshot |
| `/phasify` | Run the next phase of a saved plan |
| `/promptify pass help` | Full Npass reference |
| `/ify` | Family catalog |
