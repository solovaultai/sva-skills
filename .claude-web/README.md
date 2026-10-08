# claude.ai skills

Upload each folder in claude.ai skill settings. These files are not copied to `~/.claude/skills`. A local CLI skill with the same name wins `/askify` in the terminal. The upload is the claude.ai chat skill.

Each `SKILL.md` frontmatter uses only these six fields: `name`, `description`, `license`, `compatibility`, `metadata`, and `allowed-tools`. Extra keys fail claude.ai upload.

| Mode | Folder | What it does |
|------|--------|--------------|
| ify | `skills/ify/` | Catalog the pack and recommend which mode to open. |
| askify | `skills/askify/` | Answer the question. No edits and no plan. |
| promptify | `skills/promptify/` | Rewrite the prompt. Do not execute it. |
| plannify | `skills/plannify/` | Write a plan and end with a phase list. |
| debugify | `skills/debugify/` | Debug kickoff: hypotheses and what to check. No instrumentation and no fix. |
| addify | `skills/addify/` | Append text to the previous coaching request and redo that mode. |
