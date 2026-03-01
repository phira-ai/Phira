---
name: phira-implement-from-pseudocode
description: Realize embedded `phira_pseudocode` placeholders into runtime code, then delete implemented scaffolding.
---

Use this skill when operating `phira-implementer` in `implement from pseudocode` mode.

Goal: turn pseudocode placeholders (design intent) into correct runtime implementation with minimal pipeline disruption, then delete the implemented placeholder scaffolding.

## Inputs

- One or more embedded pseudocode placeholder blocks decorated with `@phira_pseudocode(...)`.
- Optional pseudo-call sites under `if TYPE_CHECKING:` that indicate intended wiring points.

## Principles

- Treat pseudocode as inspiration and intent, not a cage.
- Preserve the training/eval/config/checkpoint pipeline contract; prefer wiring into existing hook points.
- Default policy: no new dependencies; keep changes small and reviewable.
- Completion signal: implemented placeholders are deleted from the codebase.

## Workflow (do in order)

1) Inventory placeholders (fast)

- Search for `phira_pseudocode` and collect for each block:
  - `id`, `target`, `title`, `meta` (if any)
  - file path + surrounding pseudo-call site location (if present)
- Group by `target` so you implement end-to-end wiring, not isolated helpers.

2) Establish environment contract

- Load and follow `phira-env-contract`.
- If Python / key deps are unknown and affect implementation choices, ask one targeted question.

3) Translate placeholder intent to concrete repo code (close the symbol gap)

For each `target`, resolve what the placeholder is really asking you to do in this repository:

- Hook point reality: what inputs/objects are available at the real call site, and what lifecycle (per-step/per-epoch/per-task) applies.
- Data contract: concrete types, shapes, devices/dtypes, and where state should be owned/stored (module, optimizer, trainer, global cache).
- Missing primitives: what abstract operations need real counterparts (and whether the repo already provides utilities you should reuse).
- Feature gating: how to keep baseline behavior unchanged by default (existing flags/config patterns; add a new flag only if it matches repo convention).
- Failure modes: what to assert/log to detect silent wiring errors.

If a missing choice materially changes behavior and is not inferable from repo conventions, stop and ask one targeted question.

4) Implement runtime code

- Implement the smallest correct set of runtime helpers needed to realize the target behavior.
- Wire runtime calls at the pseudo-call site locations (or the nearest equivalent hook point).
- Keep baseline behavior unchanged unless enabled by existing config/flags (or a new flag if the repo convention requires).

5) Evidence (cheap checks)

- If approved to run commands: load `phira-cheap-checks` and run the minimal smoke checks (import, config parse, 1-10 step run, shape asserts).
- If not approved: propose exact commands + what success looks like.

6) Scaffold cleanup (required)

Once the runtime behavior is implemented and verified:

- Delete the implemented pseudocode scaffolding entirely:
  - remove the implemented `_phira_pseudo_*` definitions under `if TYPE_CHECKING:`
  - remove pseudo-call sites under `if TYPE_CHECKING:` that referenced them
  - remove now-unused `TYPE_CHECKING` / `phira_helpers.pseudocode` imports
- Do not delete unrelated/unimplemented placeholders.
- Do not add replacement tracking artifacts (no status flips, no ledger files).

## Notes / common pitfalls

- Pseudocode helper imports: placeholders often use `from phira_helpers.pseudocode import phira_pseudocode` under `TYPE_CHECKING`.
  - If the repo lacks a canonical `phira_helpers/` package (or it exists in a non-importable location), resolve it as part of implementation in an environment-compatible way.
- Treat placeholder `id` as a transient identifier: record realized ids in your final report before deletion.

## Required report additions (implementer)

- List realized placeholder ids + their realized runtime symbols/hook points.
- List which placeholder blocks/pseudo-call sites were deleted.
