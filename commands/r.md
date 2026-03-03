---
description: Invoke the Reviewer agent
agent: phira-reviewer-2
subtask: false
---

Infer the intent from the researcher's query and answer with the corresponding output format.

When the review is intended to feed `phira-hypothesizer`, end your response with a `for_hypothesizer` YAML block that includes:

- `verdict`
- `must_fix[]`
- `should_fix[]`
- `open_questions[]`
- `evidence_needed[]`

Keep each item concise, actionable, and ID-tagged (for example `R1`, `S1`, `Q1`, `E1`).
