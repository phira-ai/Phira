---
description: Invoke the Implementer agent
agent: phira-implementer
subtask: false
---

Infer for approriate mode (standard implementation, or from pseudocode) from the researcher's query and the current context, load suitable skills to accomplish the job.

Always include the implementer `archive_handoff` machine-readable YAML block in the final output.

Auto-archive integration:

- If pseudocode scaffold cleanup is completed (`archive_handoff.scaffold_cleanup: true`), archivist may be auto-triggered in `draft` mode.
- Use command arg `noarchive` to opt out for a specific run.
