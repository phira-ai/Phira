---
name: phira-archive-pointers
description: Pointer semantics for "since last record" and detected-change bookkeeping.
---

Use this skill when determining scope or updating "last record" state.

## Goal

- Make "since last record" unambiguous, branch-safe, and easy to update.
- Support detected-change workflows by storing a baseline anchor alongside the record pointer.

## Canonical pointer files

- Global fallback pointer:
  - `.archive/pointers/HEAD.yaml`
- Optional per-branch pointers (recommended to reduce merge conflicts):
  - `.archive/pointers/branches/<branch_key>.yaml`

## Branch key encoding

When mapping a git branch name to `<branch_key>`, use:

- replace `/` with `__`
- replace spaces with `-`
- replace any remaining character not in `[A-Za-z0-9._-]` with `_`

Always store the original branch name in the pointer file's `git.branch` field.

## Pointer YAML schema

### Required

- `last_record`: record ID string

### Recommended baseline anchors

At least one of:

- `git`:
  - `branch`: string
  - `head`: string (commit sha at time of update)
- `opencode` (non-git or session-based baselines):
  - `session_id`: string
  - `message_id`: string (baseline message)

## Example

---
last_record: r-20260228-archive-init
git:
  branch: main
  head: 0123abcd...

## Pointer resolution algorithm (read)

1) If git branch name is known and `.archive/pointers/branches/<branch_key>.yaml` exists, use it.
2) Else, if `.archive/pointers/HEAD.yaml` exists, use it.
3) Else, pointer is "missing" (archive not initialized).

## Pointer update algorithm (write)

- When creating new record(s), choose a single new head record ID (`new_head_id`).
- Update pointers only after:
  - record files validate
  - `graph.dot` derivation succeeds
- Update both:
  - per-branch pointer (if branch known): set `last_record: <new_head_id>`
  - global pointer: set `last_record: <new_head_id>`
- Also refresh baseline anchors when available:
  - set `git.head` to the current HEAD commit
  - set `opencode.message_id` to the message that produced the logged change (if known)

## Bootstrapping (no pointer exists)

- Create a root record with:
  - `parents: []`
  - `type: Design` (or `Decide`) and `title: "Archive initialized"`
- Write `HEAD.yaml` (and branch pointer if applicable) to point at that root record.
- Derive `graph.dot`.

## "Since last record" semantics

- The baseline is the resolved pointer's `last_record`.
- New records should use `parents: [<last_record>]` by default.
- For merges, use multiple parents.

## Detected-change semantics

Use the pointer's baseline anchors to decide whether anything changed since the last record.

- If `git.head` exists and the repo is in git:
  - treat `git.head == current HEAD` as "no change"
  - otherwise set new record `git.range: "<baseline_head>..<current_head>"`
- If only `opencode.session_id/message_id` exist:
  - prefer a plugin-provided diff since that baseline (do not guess)
- If no baseline anchor exists:
  - treat detected-change as unknown and ask the caller for scope

## Idempotency and dedupe

- If invoked repeatedly with no detected changes since baseline:
  - prefer producing a Briefing (no write), or
  - write a short checkpoint `Design` record only if the caller explicitly asked to record a checkpoint.
