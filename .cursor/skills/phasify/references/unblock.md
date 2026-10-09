# Unblock

### Unblock

Status-updating after verification (like Defer / Undefer). **No
implementation of the phase work.** Do **not** execute the blocked
phase and do **not** start later phases. Success means the unblock
*operation* is done — **not** that the phase work is `Done`.

Parse after stripping `Nimages` / `Npass`. Match `unblock` /
`Nunblock` as this mode — do **not** treat them as `undefer` /
`Nundefer`, `todo` / `Ntodo`, `todone` / `Ntodone`, or `block` /
`Nblock`. Do not treat a shared `un` prefix or shared `block`
suffix as the other mode.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `unblock` | Target the **next** phase whose Status is `Blocked` **or** `Def-Blocked` (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `Nunblock` / `pN unblock` / `unblock N` / `unblock pN` | Target that **table id** (`0`/`p0` = P0). |

If that phase is neither `Blocked` nor `Def-Blocked`: **do not
change it**. Print a clear **Error:** line (same red/bold style as
invalid defer).

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

If `Nimages` is present: acknowledge first, then Unblock. **Read**
those images when they may explain the blocker; use only what they
show (never invent APIs/files). If `Npass` > 1: extra pass(es)
improve test design / verification (see **Flags**).

**Verification loop** (required):

1. Identify the target Blocked or Def-Blocked phase.
2. Infer from this conversation + verified workspace what the blocker
   was (facts only; never invent APIs/files).
3. Design the cheapest honest test (API, CLI, file exists, HTTP,
   dashboard-equivalent command already in the repo). If no test is
   possible, say so and do **not** flip Status unless the user
   explicitly asserted the work is done **and** there is nothing to
   test. Prefer leaving `Blocked` / `Def-Blocked` and asking for
   evidence when a test is possible but unrunnable (missing creds).
4. Run the test when tools/creds exist.
5. **Pass:**
   - `Blocked` → set Status to **`Unblocked`**. Treat `Unblocked`
     like `Left` for Next / Todo selection (ready to run, not
     complete). Clear or update Reason so it no longer reads as
     blocked.
   - `Def-Blocked` → set Status back to **`Deferred`** (not
     `Unblocked`); they asked to stay deferred. Clear the blocker
     Reason (keep a remaining defer reason if one is stored and
     distinct; otherwise clear).
   Print what was verified and the updated table (show-style). Do
   **not** mark the phase `Done`.
6. **Fail** → leave Status **`Blocked`** or **`Def-Blocked`**. State
   the failure with evidence. Give the best remaining manual unblock
   instructions (same depth as the Todo report: why blocked, numbered
   manual tasks, what unblocked looks like, what not to do).

Example (only when these facts are in the conversation): a phase
blocked because an Eleven Labs agent must be deleted manually (no
programmatic delete in the story) — Unblock must check whether that
agent is gone. If still present: do not unblock; explain; leave
`Blocked`.

Display Status string on success: **`Unblocked`** (from `Blocked`)
or **`Deferred`** (from `Def-Blocked`). `Unblocked` fits the
12-wide Status column (` Unblocked  `).

