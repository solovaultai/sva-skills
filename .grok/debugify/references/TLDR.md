# /debugify

Grok Debug Mode — full loop (default). Runtime evidence loop, not a
speculative-fix loop: hypothesize → instrument → repro → analyze → fix
→ verify → clean. Alias: `/debug`.

```text
/debugify <bug report>      — full loop (default)
/debugify help              — this reference (also --help / /?)
/debugify tldr              — short form (stop)
/debugify pass              — Pass (Npass) subsection only (also pass help)
/debug <bug report>         — alias of /debugify
/debug-kickoff <bug report> — read-only brief (no edits)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<bug report>` | Full evidence loop (default): hypothesize → instrument → repro → analyze → fix → verify → clean | Runtime evidence before product fixes — not a speculative-fix loop |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `debug` | Alias of `/debugify` | Same full loop under the shorter name |
| `debug-kickoff` | Read-only brief (no edits) | Kickoff only — do not run this full loop |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` as existing evidence during Phase 0 | Visual evidence for Investigate |
| `Npass` | Extra pass(es) deepen investigation / hypothesis quality | If N > 1, pre-plan first; last pass runs this invocation’s loop work |
