---
description: Invoke the Archivist agent
agent: phira-archivist
subtask: false
---

Infer the intent and mode from the researcher's query and the current context:

- Default to `draft` (no writes).
- Use `apply` only when the researcher explicitly asks to write/update the archive (e.g. "apply", "write", "log this").
- Use `brief` when the researcher asks for a status briefing without updating files.

Follow the archive skills:

- `phira-archive-format`
- `phira-archive-pointers`
- `phira-archive-dag`

Hard constraints:

- Only write under `.archive/**`.
- No hallucinations and no secrets.
