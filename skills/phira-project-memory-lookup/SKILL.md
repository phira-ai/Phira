---
name: phira-project-memory-lookup
description: Lightweight read-only lookup of project history from .archive when prior work may affect current decisions.
---

Use this skill when historical project context is likely to change what you should recommend, build, or review.

## Purpose

- Treat `.archive/` as durable project memory maintained by `phira-archivist`.
- Pull only relevant history into the current task context.
- Avoid re-running known dead ends and avoid violating prior decisions unless explicitly revisiting them.

## When to use this skill

Use when one or more are true:

- You are about to change defaults, interfaces, eval criteria, or workflow assumptions.
- The task looks similar to earlier attempts and repeated failures are possible.
- The user asks for status/history/what was already tried or decided.
- You need rationale behind an earlier decision before proposing changes.

Do not use by default for every task. Keep lookups targeted and cheap.

## Lookup protocol (read-only)

1. Check whether `.archive/` exists.
2. Resolve baseline pointer:
   - Prefer `.archive/pointers/branches/<branch_key>.yaml` when branch pointer exists.
   - Else use `.archive/pointers/HEAD.yaml` if it exists.
   - If neither exists, memory is unavailable; continue without archive context.
3. Read `last_record` from the pointer, then read `.archive/records/<last_record>.md`.
4. If more context is needed, walk `parents` lineage with caps:
   - max depth: 8
   - max records total: 12
5. If task-specific context is needed, run keyword search over `.archive/records/*.md`:
   - use 2-5 focused keywords from user intent
   - read only top matches needed (cap at 10 files)

## Output: memory packet

When this skill is used, produce a compact memory packet for the caller/output:

- `records`: ordered list of relevant record IDs (newest first)
- `constraints`: active constraints that should affect current work
- `decisions`: prior decisions and why they were made
- `failures`: known failure modes/negative results worth avoiding
- `open_questions`: unresolved issues that may block confidence
- `evidence`: file paths used (pointer + record files)

Keep the packet short and high-signal.

## Usage rules

- Cite record IDs and paths whenever archive history materially influences your answer.
- Treat archive records as strong context, not unquestionable truth.
- If the user explicitly asks to revisit or overturn a prior decision, do so explicitly.
- Never invent record content. If details are missing, say so.

## Graceful fallback

- If `.archive/` is missing, uninitialized, or inconsistent, proceed normally and note that no archive memory was available.
