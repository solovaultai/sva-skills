# Runblock

### Runblock

**User-asserted unblock then run-or-mark-Done** those phases in one
step. Skip Unblock’s verification loop (no ack wait; same
assertiveness as rundefer / todone). `runblock` ≠ `unblock` ≠
`block` ≠ `rundefer`. Do not collapse on `run` / `un` / `block`.
**`unblock` still only verifies** (no execute). **`runblock` =
unblock + execute remaining work, or mark `Done` when nothing is
automatable.**

Parse after stripping `Nimages` / `Npass`. If `Nimages` is present:
acknowledge first, then Runblock. Match `runblock` / `Nrunblock` /
`runblockN` as this mode **first** — the token contains `block` and
`run`. Do **not** treat them as `block` / `Nblock`, `unblock` /
`Nunblock`, or `rundefer` / `Nrundefer`.

| Text | Effect |
|------|--------|
| `runblock` | Unblock the **next 1** Blocked or Def-Blocked phase (plan order), then run remaining work or mark `Done`. |
| `runblock N` / `Nrunblock` / `runblockN` (N ≥ 1) | Unblock the **next N** Blocked / Def-Blocked phases, then run-or-mark them in plan order (like Next-N on those just-unblocked phases). |
| `2runblock` / `runblock2` / `Runblock2` | Same as `runblock 2` — **next 2** blocked, **not** named P2. |
| `runblock pN` / `runblock PN` / `runblockpN` / `runblockPN` / `pN runblock` / `PNrunblock` | Named: that phase **only if** it is `Blocked` or `Def-Blocked`; else **Error:** |
| `runblock 0` / `0runblock` / `runblock0` | **Error:** (cannot “next 0”; use `runblock p0`). Not named P0. |

**Parse collision (required):** `runblock N` / `Nrunblock` /
`runblockN` / `2runblock` / `runblock2` means **next N blocked**,
not named PN (like `rundefer N` / `explain N` — and **unlike**
`Nblock` / `2block` / `Nunblock` / `2unblock`, which are named PN).
Named runblock is only the `P`/`p` family. `runblock 0` /
`0runblock` / `runblock0` is not “next 0” — **Error:** (use
`runblock p0` to target P0). `runblock` ≠ `unblock` ≠ `block` ≠
`rundefer`.

**Semantics:**

1. Find targets: next N phases with Status `Blocked` or
   `Def-Blocked` (skip Done, Left, Deferred-without-block,
   Unblocked, Progress, Planned, Not started, etc.).
2. If **none**: say so and print the table (show-style). Do **not**
   execute some other open phase.
3. If **fewer than N**: unblock+run-or-mark all found; say the
   shortfall.
4. **Unblock first** so the phase is runnable (skip Unblock’s
   verification loop — user-asserted; no ack wait):
   - `Blocked` → treat as cleared (`Unblocked` / ready)
   - `Def-Blocked` → clear **both** block and defer (`Left` /
     ready) so it can actually run (unlike **unblock** →
     `Deferred`, unlike **rundefer** → `Blocked` and stop)
5. **Then run or mark as run:**
   - Remaining **agent-automatable** work → normal phasify
     **Execute** (banners + last-of-run table). `Done` only if
     work landed.
   - **No remaining automation** (typical blocked gate: human
     work already done, nothing for the agent) → mark Status
     **`Done`**, short note, no Todo briefing, no fake implement.
     Clear blocker Reason (e.g. closed by runblock).
6. Sequential, plan order, like rundefer. Stop the sequence if a
   just-runblocked phase becomes `Blocked` again. Do not wait for
   ack. Nimages ack first if present. `Npass` = multi-pass of
   **this runblock run** (that mode’s work), not a whole-table
   replan.

Invalid named id, or named runblock of a phase that is neither
`Blocked` nor `Def-Blocked`: **do not change it** and **do not
execute**. Print a clear **Error:** line (same red/bold style as
invalid unblock).

Accepted tokens (all of these):

```text
/phasify runblock
/phasify runblock P0
/phasify runblock p0
/phasify runblock 1
/phasify runblockP0
/phasify P0runblock
/phasify 1runblock
/phasify 2runblock
/phasify2runblock
/phasify 2runblock
/phasify runblock2
/phasify runblock p1
/phasify p1 runblock
```

`2runblock` = next 2 blocked, **not** P2. Named is **only** the
`P`/`p` family.

