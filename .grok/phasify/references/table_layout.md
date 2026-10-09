# Table layout

## Table layout (mandatory — `phase_layout.txt`)

Misaligned borders make the table unreadable. Copy this layout exactly.
**Do not** use a markdown table. **Do not** merge or span cells. **Do not**
put the original ify text in its own box.

Print the table inside a fenced `text` code block so the chat cannot
reflow the lines.

If the workspace has `docs/phase_layout.txt`, or this skill folder has
`phase_layout.txt`, match that file's column widths. The copy next to
this skill is the installed source of truth.

### Fixed widths (every line is **exactly 89** characters)

Match `docs/phase_layout.txt`. Status is **12** so `Understood` fits.

| Piece | Inner width | `│` column index |
|-------|-------------|------------------|
| Phase | **15** | left border = 0; after Phase = **16** |
| Description | **58** | after Description = **75** |
| Status | **12** | right border = **88** |

`1 + 15 + 1 + 58 + 1 + 12 + 1 = 89`. Count characters before sending.
If any line is not 89, or any `│` is not in columns 0 / 16 / 75 / 88,
rebuild the line. No trailing space after the right border.

### Characters

- Single-line box only: `┌┬┐ ├┼┤ └┴┘ │ ─` (not `╔═╗`, not markdown pipes).
- Pad with spaces — **never tabs**.
- Cell text: one leading space, then content, then spaces to the inner
  width. Example Phase ` P0 — Spec     ` (15), Status ` Done       ` (12).
  Task / Flags use a two-space indent as in the layout (`  Task`,
  `  Flags`).

### Wrap — keep the three columns on every line

Long text wraps **inside Description only** (max **56** characters of
content after the leading space). Word-wrap; never overflow a cell.

- **Task** (verbatim original ify text): Status `Planned` on the **first**
  Task line only; blank after. First Task line has a blank Phase; label
  `Task` on the next line; further wraps blank Phase. See **Capture Task
  and Flags**.
- **Flags** (both / one / none — see **Capture Task and Flags**): one
  Description line per present flag (`Caught and correctly interpreted
  <token>. On pass k of N.`). Phase `Flags` and Status `Understood` on
  the first Flags line only; blank after. Omit the row if neither flag
  was included.
- **Work phases:** Phase id (`P0 — Spec`) and Status on the **first**
  wrap line only; continuations have a blank Phase and a blank Status.

Row separators always keep three columns (`┼` / `┬` / `┴`). Never
collapse a separator across the full table width.

### Reason column (`show` / recap)

If any phase has a stored reason, add a **Reason** column on
`show`/`refresh` only (keep the 3-column execute recap unless a reason
exists — then include Reason so it is retrievable quickly). Reprint the
stored reason on every recap/show. Omit the column entirely if no phase
has a reason. Align with box-drawing; not a markdown table. 3-column
lines stay exactly 89 characters (`phase_layout.txt`); when Reason is
present, keep every line the same width.

### Row order

1. Column titles: `Phase` / `Description` / `Status` (and **Reason** when
   any phase has a stored reason)
2. **Task** — verbatim original ify Task text (promptify / askify /
   runnify / plannify / debugify / addify). When the plan came from
   `/addify`, use the combined text. No generated plan text. See
   **Capture Task and Flags**.
3. **Flags** — both flags, one flag, or omit the row (neither present)
4. Work phases in order, current statuses (Reason on that row when stored)

### Status words (must fit in 12 with the leading space)

Use exactly: `Planned` · `Done` · `Left` · `Blocked` · `Unblocked` ·
`Deferred` · `Def-Blocked` · `Progress` · `Understood`. Do **not**
write `In progress` (too long). `Unblocked` fits the 12-wide Status
column (` Unblocked  `). `Def-Blocked` is the table spelling of
canonical **Deferred-Blocked** (16 chars; does not fit). `Def-Blocked`
is 11 and fits (` Def-Blocked`). Treat `Unblocked` like `Left` for
Next / Todo selection. Skip `Def-Blocked` like `Deferred` for Next /
bare Todo. Mark from this run + prior **verified** work only.

### Canonical example (copy these widths)

This is `docs/phase_layout.txt` — 89 characters per line. Both flags
present ⇒ two Flags Description lines. Copy this file next to the skill
when widths drift.

```text
┌───────────────┬──────────────────────────────────────────────────────────┬────────────┐
│ Phase         │ Description                                              │ Status     │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│               │ I want to add an icon  to campaigns that will be used    │ Planned    │
│  Task         │ wherever the campaign is used for quick identification.  │            │
│               │ If none is supplied the icon should be a badge           │            │
│               │ <text cut but will be shown by cursor and grok>          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│  Flags        │ Caught and correctly interpreted 1image. On pass 1 of 2. │ Understood │
│               │ Caught and correctly interpreted 2pass. On pass 1 of 2.  │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P0 — Spec     │ Freeze I1–I8 in DESIGN_FLUENT_CAMPAIGN_ICON.md + PRODUCT │ Done       │
│               │ row; initials examples including EEFF2                   │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P1 — Mark     │ campaignInitials + CampaignMark; tests; initials on      │ Done       │
│               │ campaign lists with no API                               │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P2 — API      │ 081_campaign_icon.sql icon_url; PATCH/POST; series       │ Done       │
│               │ campaign_icon_url; Console tests                         │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P3 — Edit     │ Properties Identity + create dialog URL field on         │ Done       │
│               │ existing instance-edit snapshot                          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P4 — Tables   │ Per-row nameIcon; campaign lists + run Campaign column,  │ Done       │
│               │ 20px                                                     │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P5 — Surfaces │ Blade title, picker, runner, Home campaign rows, run     │ Left       │
│               │ essentials campaign label                                │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P6 — Bake     │ PRODUCT greps, rebuild Fluent, Console tests green       │ Left       │
└───────────────┴──────────────────────────────────────────────────────────┴────────────┘
```

---

