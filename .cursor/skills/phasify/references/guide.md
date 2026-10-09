# Guide

### Guide

`guide` is an optional **second word** on a tell: `explain`,
`tldr` (a phase tell, not the short page), or `dummy`.
Examples: `explain guide`, `tldr guide p3`, `dummy guide`,
`dummy guide 2`, `3explain guide`. It is **not** a mode of its
own. It is **not** `runblock`. Existing `runblock` stays
unblock, then execute or mark `Done`.

Match `coach` before `guide`. `coach guide` is coach with an
extra token: **Error:** coach does not take `guide`. A leading
`guide` (no tell in front) is **Error:** `guide` is a second
word on explain, tldr, or dummy. Do not execute.

Read this file only when that second word is present. The tell’s
mode file still selects the phase (`explain.md` or `dummy.md`;
a tldr phase tell uses the tldr section of `explain.md`).

**Do not** change Status. Do **not** execute. Do **not** reprint
or rewrite the phased plan.

**Only when every target is blocked or partially blocked.**
Blocked: Status `Blocked` or `Def-Blocked`. Partially blocked:
same record as howto (`Progress` / `In progress` with a Reason,
or this conversation stopped that phase on a human step). If any
target is not blocked or partially blocked: **Error:** and do
not write a file. Do not fall through to the shallower tell.

**User-guide depth** on top of that tell. The tell’s depth still
applies:

- **dummy** — non-technical. No commands, paths, or APIs. Task
  names stay too short to perform.
- **tldr** — the explanation only, plus a numbered list a
  capable technologist could carry out. No process narration.
  No followup.
- **explain** — the full write-up, plus detailed instructions
  from the phase record and verified workspace facts only.

On top of that depth, always:

- A mermaid flowchart of the path (in the reply; not a repo
  file). Another diagram when a step branches.
- Web images, links, and PDFs only when the source allows reuse.
  Same bar as howto: public domain, Creative Commons, or an
  official vendor doc you may link. Cite title, URL, and
  license. Do not copy those files into the repo. Do not invent
  pixels. If nothing reusable turns up, say so and keep the
  diagram.

**Done** is not a guide target (a named Done phase is not
blocked). Count selectors still skip `Done`.

**No plan:** `/plannify` first. Do not write a file.
**None eligible:** say so. Do not rewrite the plan. Do not write
a file.

### Write the file

Cite `docs/docify_contract.md`. One file per target phase. Do
not invent a second path. Do not commit the file.

1. Read the defaults store when it exists:
   `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/docify.env`.
   Use `path`, `format`, and `prefix`.
2. Directory: stored `path` when set. Otherwise
   `/home/ami/src/pytch/pytch-docs/agent/`.
3. The default folder requires the pytch-docs checkout. If that
   checkout is missing: **Error:** pytch-docs not found. Do not
   invent another folder. Do not write.
4. Format: stored `format` when set. Otherwise markdown (`.md`).
   Follow the contract for txt, docx, and html bytes.
5. Name: generated `CAPS_WITH_UNDERSCORES` from the phase title
   (three to six words). Apply a stored `prefix` to that
   generated name. If the title is empty, the name is `GUIDE`.
6. Create `agent/` on first use of the default folder.
   Overwrite an existing target. The reply may create or
   overwrite only this resolved file.

Print the reply, then:

```text
**Docify — wrote.**
`<absolute path>`
```

No phase table after that line. Cite `docs/window_title.md`:
the name uses the phase this guide is about.

```text
## Guide — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>
**Depth:** dummy | tldr | explain

### Guide
<user-guide prose at that tell’s depth>

### Path
<mermaid of the path>

### Pictures and sources
<title, URL, license — or none reusable>

### Do not
- Do not execute
- Do not change Status
- Do not copy web files into the repo
- Do not invent pixels
- Do not rewrite or reprint the phased plan
- This is not runblock
```

```text
/phasify explain guide
/phasify tldr guide p3
/phasify dummy guide
/phasify dummy guide p0
```
