---
description: Invoke the Hypothesizer agent
agent: phira-hypothesizer
subtask: false
---

Infer the appropriate mode (idea formation, brainstorm from goal, paper discussion, paper summarisation, revision from reviewer feedback) from the researcher's query and answer with the corresponding output format.

If reviewer feedback is present in context (especially a `for_hypothesizer` block), switch to revision mode and:

- explicitly list the reviewer item IDs you are addressing,
- include a feedback resolution matrix (`feedback_id`, `action`, `change_made`, `rationale`),
- and list unresolved items with next actions.

Revision mode default is incremental: revise existing option cards by ID/title and avoid regenerating a full 3-5 card set unless reviewer feedback blocks the core premise, the user requests regeneration, or prior cards are unavailable.
