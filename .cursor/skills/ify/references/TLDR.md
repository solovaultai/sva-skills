# Ify tldr — template + extraction rules

Not a per-verb help page. Agents extract a narrative-free tldr from
the **same sources** extreme help uses. Do **not** invent flags,
arguments, examples, or aliases. Omit any row that is not in the
source.

`/ify tldr` (no verb) extracts from **ify’s** own `references/HELP.md`
in this skill folder. `/ify tldr <verb>` extracts from that verb
(this tree). Resolve aliases first (ify `SKILL.md` alias table).

---

## Output shape (mandatory — no other sections)

Print **exactly** these four blocks, in this order. No intro, no
“what it does” prose, no Related, no Hard rules, no status table.

```text
<one-line description>

<syntax diagram>

| Argument | Meaning |
|----------|---------|
| …        | …       |

| Example | Effect |
|---------|--------|
| …       | …      |
```

If a source has no extractable arguments, omit the args table
entirely (do not print an empty table or a placeholder row).
Same for examples.

---

## Source (this tree only)

Same source map as extreme help. Read the verb’s folder in **this**
tree (`.cursor/skills/<verb>/` or `~/.cursor/skills/<verb>/`).

1. Prefer `references/HELP.md` when that file exists.
2. Else the `## User help` section of that verb’s `SKILL.md` (if
   present).
3. If neither exists: print short usage + known-verb list. Stop.
   Do not invent a tldr.

Do **not** read the other tree. Do **not** reconcile Cursor vs Grok.

---

## Extraction rules

Copy wording from the source. Tighten only by dropping narrative
sentences. Never add a token, flag, alias, or mode that the source
does not name.

### One-line description

First sentence of `## What it does` (HELP.md), else the YAML
`description` first sentence, else the first sentence after the
skill title. One line. No second sentence.

### Syntax diagram

Prefer the first ` ```text ` block under `## How to invoke`.
If that heading is missing, use the first ` ```text ` block under
`## What it does`, or the empty-invocation usage block in
`SKILL.md`. Print the block as a syntax diagram (the lines that
show `/<verb> …`). Do not add lines.

### Arguments table

Extract only tokens the source already treats as arguments or
subcommands (for example `<prompt>`, `<text>`, `<verb>`,
`<bug report>`, `fromhere`, `help`, `pass`, named `pN` / `next`
when those words appear in How to invoke or Modes).

| Column | Content |
|--------|---------|
| Argument | The token as spelled in the source |
| Meaning | The source’s short gloss on the same line or Modes row |

**Flags:** include `Nimages` / `Npass` (or `1image` / `2pass`)
**only** if that verb’s HELP.md or User help already documents
them. Do not copy promptify’s flag list onto a verb that does
not mention flags. Do not invent `-2pass` unless the source
names it.

Omit rows not in the source. Do not add “optional” / “required”
unless the source says so.

### Examples table

Extract only concrete invocations the source already shows
(How to invoke examples, ` ```text ` lines that are sample
commands, or a Modes “Invocation” cell that is a full command).

| Column | Content |
|--------|---------|
| Example | The command as written in the source |
| Effect | The source’s gloss (Modes “What happens”, or the `—` clause on the same line) |

Do not invent examples (including the pytch/ptych which example
unless the verb is **ify** and ify’s HELP.md already has it).

---

## Aliases (resolve, then extract the canonical)

| User token | Canonical | This tree |
|------------|-----------|-----------|
| `promptify-plan`, `planify` | plannify | both |
| `promptify-run` | runnify | both |
| `promptify-ask` | askify | both |
| `promptify-debug` | debugify | **Cursor** |
| `ify` | ify | both — extract from ify’s HELP.md |

Unknown token / Not ify: do **not** extract. Print ify’s short
usage + the known-verb list from ify `SKILL.md` (and
`not an ify; use /<name> help` when the token is a listed Not
ify utility). Same path as `/ify help <unknown>`.

---

## Hard rules

- No narrative outside the four blocks.
- No invented flags, args, examples, or aliases.
- Omit tables/rows the source does not support.
- Do not dispatch, plan, execute, debug, or answer a domain
  question.
- Do not print extreme help from tldr (and vice versa).
