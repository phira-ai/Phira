# Skills Ownership Map

This file documents which Phira agent primarily owns each local skill, and which agents usually collaborate with it.

- **Owner**: the agent expected to apply the skill directly.
- **Works with**: agents that commonly consume the output or participate in the same workflow.

## `phira` (orchestrator)

| Skill                              | Works with                                                                                           |
| ---------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [`phira-orchestration-contract`](phira-orchestration-contract/SKILL.md) | `phira-prototyper`, `phira-hypothesizer`, `phira-implementer`, `phira-reviewer-2`, `phira-archivist` |
| [`phira-conference-search-pipeline`](phira-conference-search-pipeline/SKILL.md) | optional venue-search skill/tool (`search-conference`) |
| [`phira-paper-summary-pipeline`](phira-paper-summary-pipeline/SKILL.md) | `phira-hypothesizer`, `phira-reviewer-2`, `phira-archivist` |
| [`phira-project-memory-lookup`](phira-project-memory-lookup/SKILL.md) | `phira-hypothesizer`, `phira-prototyper`, `phira-implementer`, `phira-reviewer-2`, `phira-archivist` |

## `phira-hypothesizer`

| Skill              | Works with         |
| ------------------ | ------------------ |
| [`phira-idea-cards`](phira-idea-cards/SKILL.md) | `phira-prototyper` |

## `phira-prototyper`

| Skill                           | Works with          |
| ------------------------------- | ------------------- |
| [`phira-prototype-contract`](phira-prototype-contract/SKILL.md) | `phira-implementer` |
| [`phira-pseudocode-placeholders`](phira-pseudocode-placeholders/SKILL.md) | `phira-implementer` |

## `phira-implementer`

| Skill                             | Works with                                            |
| --------------------------------- | ----------------------------------------------------- |
| [`phira-implement-from-pseudocode`](phira-implement-from-pseudocode/SKILL.md) | `phira-reviewer-2` |
| [`phira-env-contract`](phira-env-contract/SKILL.md) | `phira` (for missing constraints), `phira-reviewer-2` |
| [`phira-cheap-checks`](phira-cheap-checks/SKILL.md) | `phira-reviewer-2` |
| [`phira-baseline-parity`](phira-baseline-parity/SKILL.md) | `phira-reviewer-2` |

## `phira-reviewer-2`

| Skill                        | Works with                    |
| ---------------------------- | ----------------------------- |
| [`phira-impl-vs-claim-audit`](phira-impl-vs-claim-audit/SKILL.md) | `phira-implementer`, `phira` |
| [`phira-limitations-contract`](phira-limitations-contract/SKILL.md) | `phira-hypothesizer`, `phira` |

## `phira-archivist`

| Skill                    | Works with |
| ------------------------ | ---------- |
| [`phira-archive-format`](phira-archive-format/SKILL.md) | `phira` |
| [`phira-archive-pointers`](phira-archive-pointers/SKILL.md) | `phira` |
| [`phira-archive-dag`](phira-archive-dag/SKILL.md) | `phira` |
