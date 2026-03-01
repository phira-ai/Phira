---
name: phira-orchestration-contract
description: Planning + approval + execution contract for the Phira primary orchestrator.
---

Use this skill for any task where `phira` will perform multi-step work, use tools beyond read-only exploration, change files, run commands, or invoke subagents.

## Golden rule

- Plan first. Execute only after explicit user approval.
- Before approval: do NOT call `todowrite` and or `task`.

Exception (direct research answer mode only): `phira` may invoke read-only subagents to improve a direct research answer.

## Mode decision

Mode "direct answer" if ALL are true:

- The user wants an explanation or guidance.
- No deliverables are requested (no files, no commands, no iterations, no repo changes).

Otherwise use orchestrated execution.

## Required plan template for orchestrated execution

Your plan MUST be concrete and include these sections.

1. Goal

- What "done" means.

2. Subagents and roles

- List only those you will use.
- For each: purpose + expected output.

3. Execution steps (ordered)

- 4-10 numbered steps.

4. Iterations and stop conditions

- Loops: define which stages repeat and maximum rounds.
- Stop on success when acceptance criteria met.
- Stop and ask a targeted question only if blocked by missing info that changes the outcome.

5. Risks / unknowns

- The few highest-impact uncertainties.

6. Deliverables

- Paths, artifacts, or outputs.

End the plan with a single line asking for approval, e.g.:

"Reply 'approve' to execute this plan, or tell me what to change."

## After approval: TODO + execution

1. Create a TODO list that mirrors the approved plan steps.

- Keep items small and verifiable.
- Exactly one item `in_progress` at a time.

2. Execution rules

- Prefer parallel subagent calls when independent.
- For each subagent call, provide a context packet:
  - task objective + constraints
  - required output format
  - evidence/citation requirements
  - explicit non-goals

3. Report progress

- Update TODO status as you go.
- If iteration is needed, state why and how many rounds remain.

