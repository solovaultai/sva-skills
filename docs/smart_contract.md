# Family `smart` contract

Shared contract. Lives in `docs/` like `docs/phase_layout.txt`.
Every verb that implements `smart` **cites this file**. Do not fork
a second preamble, implicit policy, or Error dialect.

```text
/<verb> smart <prompt>
```

---

## Parse (every verb)

Strip `Nimages` / `Npass` first (promptify **Flag parse order**).
Then reserved token `smart`.

- Empty `smart` (no prompt): that verb’s short usage + “smart needs
  a prompt.” Do not invent a selection.
- Flags are **not** prompt wording. They apply to the **selected**
  action after dispatch (phasify) or to this recommend pass (ify).

---

## Mandatory preamble

Print this **before anything else** except scratch / Npass acks:

```text
**Smart — selected.**
`/<verb> <canonical invocation>`
<one-line why>
```

Exact heading. Exact backtick line. Why is one short sentence.

---

## After-select hook (the only per-verb fork)

| Verb | After-select |
|------|----------------|
| **ify** | **Stop.** Recommend only. Never dispatch. |
| **phasify** | **Dispatch** the selected invocation as if the user typed it. No ack. |
| Future verbs | Document in that verb’s `references/SMART.md`. |

---

## Implicit smart

Opt-in per verb.

| Verb | Implicit? |
|------|-----------|
| **ify** | **Yes.** Bare `/ify <prompt>` is implicit smart. |
| **phasify** | **No.** Bare NL stays the existing parse (Next / `3` / `done` / `-2` / …). |
| Future verbs | **No**, unless that verb’s `references/SMART.md` says yes. |

---

## `which`

Alias of `smart` on **ify only**. Explicit `/ify which …` still
works. Not a phasify mode. Not a reserved token on other verbs.

---

## Npass

If N > 1, pass 1 is a documented pre-plan of the **selection**
(inventories / candidate modes / live plan ids). Last pass prints
the preamble and runs the after-select hook.

---

## Error

Do not guess. Print **Error:** + enough context. No dispatch.

- Phasify with no current plan: **Error:** `/plannify` first.
- Phasify ambiguity: **Error:** + current table.
- Invalid / empty smart: short usage + “smart needs a prompt.”
  (ify: same for empty `which`.)

**Error:** style matches the verb’s existing Error lines (phasify:
red via HTML `<span style="color:red">` when the client will render
it; otherwise bold `Error:`).

---

## Adding smart to a verb

1. Copy a `references/SMART.md` (decision table + live-resolve +
   frozen examples). Do not invent a second output shape.
2. Cite this file from that SMART.md and a **thin** SKILL dispatch
   row (`smart` after flag strip; remainder is the prompt).
3. Set after-select (stop vs dispatch) and implicit yes/no in
   SMART.md.
4. Add one How-to-invoke line in that verb’s HELP.
5. Add the command to README (both Grok and Cursor catalogs).
6. Do not add empty SMART.md stubs to verbs that are not shipping
   smart yet.
