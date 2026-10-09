# Rundefer

### Rundefer

**Undefer then execute** those phases in one step — as if `/phasify`
ran after the undefer, but only on the just-undeferred ids. Do **not**
wait for ack. `rundefer` ≠ `undefer` ≠ `toend` ≠ `todo` ≠ `todone`.
Do not collapse on `un` / `defer` / `run`. **`undefer` still only
changes Status** (no execute). **`rundefer` = undefer + execute.**

Parse after stripping `Nimages` / `Npass`. If `Nimages` is present:
acknowledge first, then Rundefer. Match `rundefer` / `Nrundefer` /
`rundeferN` as this mode **first** — the token contains `undefer` /
`defer`. Do **not** treat them as `undefer` / `Nundefer` or `defer` /
`Ndefer`.

| Text | Effect |
|------|--------|
| `rundefer` | Undefer the **next 1** Deferred or Def-Blocked phase (plan order), then execute it. |
| `rundefer N` / `Nrundefer` / `rundeferN` (N ≥ 1) | Undefer the **next N** Deferred / Def-Blocked phases, then execute them in plan order (like Next-N on those just-undeferred phases). |
| `2rundefer` / `rundefer2` / `Rundefer2` | Same as `rundefer 2` — **next 2** deferred, **not** named P2. |
| `rundefer pN` / `pN rundefer` | Named: that phase **only if** it is `Deferred` or `Def-Blocked`; else **Error:** |

**Parse collision (required):** `rundefer N` / `Nrundefer` / `rundeferN`
/ `2rundefer` / `rundefer2` means **next N deferred**, not named PN
(like `block 2` / `todone 2` — and **unlike** `Nundefer` / `2undefer` /
`Nblock` / `2block`, which are named PN). Named rundefer is only `pN`.
`rundefer 0` / `0rundefer` is not “next 0” — **Error:** (use
`rundefer p0` to target P0). `rundefer` ≠ `undefer` ≠ `toend` ≠
`todo` ≠ `todone`.

**Semantics:**

1. Find targets: next N phases with Status `Deferred` or `Def-Blocked`
   (skip Done, Left, Blocked-without-defer, Unblocked, Progress,
   Planned, Not started, etc.).
2. If **none**: say so and print the table (show-style). Do **not**
   execute some other open phase.
3. If **fewer than N**: undefer+run all found; say the shortfall.
4. **Undefer first** (same transitions as **Undefer** — do not change
   Undefer’s no-execute behavior):
   - `Deferred` → `Left` (clear defer Reason)
   - `Def-Blocked` → `Blocked` (keep blocker Reason) — then execute
     **stops** on that phase like any Blocked phase. Do **not** pretend
     it became runnable.
5. **Then execute** the just-undeferred phases that are now `Left` /
   `Unblocked` / runnable, in plan order, as a normal phasify execute
   (Named / Next semantics on those ids). Stop at `Blocked`. Skip if
   somehow still `Deferred`. Print COMPLETED / BLOCKED banners and the
   last-of-run table per **Execute** / **Phase COMPLETED banner**.
6. Do not wait for ack. Nimages ack first if present. `Npass` = multi-pass
   of **this rundefer run** (that mode’s work), not a whole-table replan.

If the first just-undeferred phase is `Blocked` (was `Def-Blocked`):
print the BLOCKED banner and the last-of-run table; do not start later
just-undeferred phases; do not pick some other Left phase that was
never a target.

Invalid named id, or named rundefer of a phase that is neither
`Deferred` nor `Def-Blocked`: **do not change it** and **do not
execute**. Print a clear **Error:** line (same red/bold style as
invalid undefer).

