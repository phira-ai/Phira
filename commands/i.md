---
description: Invoke the Implementer agent
agent: phira-implementer
subtask: false
---

Infer for approriate mode (standard implementation, or from pseudocode) from the researcher's query and the current context, load suitable skills to accomplish the job.

Always include the implementer `archive_handoff` machine-readable YAML block in the final output.

Auto-archive integration:

- Use command arg `noarchive` to opt out of the *external* auto-archive trigger for a specific run.
