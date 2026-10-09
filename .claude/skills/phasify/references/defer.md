# Defer

### Defer

Non-executing. Update the current plan’s status and keep the reason on
that row. If `Nimages` is present: acknowledge first (see **Flags**),
then Defer. Strip flags **before** taking the reason.

| Text | Effect |
|------|--------|
| `defer` | Defer the **next open** phase (same “next incomplete” rule). If none, say so — do not invent a target. |
| `Ndefer` / `pN defer` / `defer N` / `defer pN` | Defer that **table id** (`0`/`p0` = P0). |

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not defer**. Print a clear **Error:** line (red via HTML
`<span style="color:red">` when the client will render it; otherwise
bold `Error:`).

Optional reason: remainder of the line after the defer token
**and after flag strip** (`defer API freeze` / `2defer waiting on legal`).
`2pass` / `1image` are flags, never reason text. Store on the phase
permanently for this plan (reprint on every recap/show). Empty reason
is allowed.

Future execute modes **skip** `Deferred` and `Def-Blocked` unless the
user explicitly says to run that phase (`pN`, `redo`, `--force`).

