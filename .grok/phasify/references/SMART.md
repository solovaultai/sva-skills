# Phasify smart — mode decision + live resolve

Cite `docs/smart_contract.md`. `/phasify smart <prompt>` only.
**Not** Next. **Not** implicit on other tokens. `which` is **not**
a phasify mode.

After flag strip, first token `smart` → this mode. Remainder is
the prompt. Empty `smart`: short usage + “smart needs a prompt.”

**After-select:** print the family preamble, then **dispatch** the
selected invocation as if the user typed it. No ack wait. Then
run that mode’s existing SKILL path (Todone briefing + Done,
Stop-before-end execute, Runblock, …) including banners / 89-char
table.

---

## Output shape (mandatory)

Family preamble (`docs/smart_contract.md`), after scratch / Npass
acks if those flags are present:

```text
**Smart — selected.**
`/phasify <canonical invocation>`
<one-line why>
```

Then dispatch. Do not wait for acknowledgement.

---

## Live resolve (required)

Recover the current plan table (same locate-plan rules as
phasify SKILL). **Never invent phases.**

- No plan → **Error:** `/plannify` first. No dispatch.
- Ambiguity → **Error:** + current table. No dispatch.

Then bind phrases to **live** ids:

| Phrase | Bind to |
|--------|---------|
| “next deferred” | first Status `Deferred` or `Def-Blocked` |
| “next blocked” | first Status `Blocked` or `Def-Blocked` |
| “next” | next incomplete (not `Done` / `Deferred` / `Def-Blocked`) |
| “remove next” / “delete next” | **remove** (next not-Done; still confirms) |
| “remove PN” / a unique phase title | **remove pN** / `remove <title>` |
| “N before the last” / “all but last N” | Stop-before-end `-N` (`C - N`) |

Prefer the **single** existing mode that achieves the whole ask
(EX-1 is `todone p3`, not `undefer` then `todone`).

---

## Decision table (first matching row wins)

| Prompt is mainly… | Select |
|-------------------|--------|
| Undefer **and** mark done / close a deferred | **named todone** `todone pN` (bare todone skips Deferred) |
| Unblock **and** run / execute the blocked | **runblock** `runblock pN` (assume runblock exists) |
| Undefer **and** run | **rundefer** |
| Undefer only | **undefer** |
| Unblock / verify only | **unblock** |
| Run until N before last / all but last N | **Stop-before-end** `-N` |
| Run remaining / to the end | **Run-to-end** `done` |
| Next N phases | **Next-N** |
| Named phase / run PN | **Named** `pN` |
| Next / continue | **Next** |
| Defer / park | **defer** |
| Block | **block** |
| Todo / checklist | **todo** |
| Explain | **explain** |
| Show / refresh table | **show** |
| Remove / delete phase(s) from the plan | **remove** (`delete` alias; named `pN` / title, or next N not-Done) |
| Mark done / already did (not deferred-specific) | **todone** (named if target is Deferred) |

---

## Frozen examples (acceptance)

Write these into this file. Live-resolve the id / count against
the **current** plan; the examples freeze the *shape*.

### EX-1 — undefer next deferred + mark done

Prompt: `smart "undefer the next deferred phase and mark it as done"`

Live: next Deferred = **P3**

Select and run:

```text
/phasify todone p3
```

Preamble:

```text
**Smart — selected.**
`/phasify todone p3`
Undefer-and-close a deferred phase is named todone (bare todone skips Deferred).
```

### EX-2 — run until 2 before last

Prompt: `smart "run phases until 2 before the last phase"`

Live: **5** work phases (Done rows are skipped by execute)

Select and run:

```text
/phasify -2
```

Preamble:

```text
**Smart — selected.**
`/phasify -2`
Stop-before-end: last included index is C − 2. Do not invent Next-N.
```

### EX-3 — unblock and run next blocked

Prompt: `smart "unblock and run the next blocked phase"`

Live: next blocked = **P7**

Select and run:

```text
/phasify runblock p7
```

Preamble:

```text
**Smart — selected.**
`/phasify runblock p7`
Unblock-and-run is runblock (assume that mode exists). Do not invent a second path.
```

---

## Npass

If N > 1, pass 1 is a documented pre-plan of the **selection**
(candidate modes / live plan ids). Last pass prints the preamble
and dispatches.

Flags apply to the **selected** action after dispatch.

---

## Hard rules

- Cite `docs/smart_contract.md`. Do not fork the preamble.
- Live-resolve only. Never invent plan phases or ids.
- No plan / ambiguity: **Error:**. No dispatch.
- After preamble, dispatch. No ack.
- Not implicit. Bare `/phasify` stays Next.
- `which` is ify-only. Not a phasify token.
- Do not implement runblock here; only **select** `runblock pN`
  when that is the right action (EX-3).
