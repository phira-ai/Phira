---
name: phira-archive-format
description: Canonical per-record archive format (YAML front matter + Markdown body).
---

Use this skill when writing or updating `.archive/**`.

## Directory layout (canonical)

- `.archive/records/`: per-record files (canonical source of truth)
- `.archive/pointers/`: pointer files ("since last record" state)
- `.archive/graph.dot`: derived Graphviz/DOT (committed)

## Record file format

- Each record is a Markdown file with:
  - YAML front matter between `---` lines
  - a short Markdown body
- Records must be:
  - human readable
  - machine parseable
  - stable over time (avoid ephemeral noise)

## Record ID and filename

- Filename: `<record_id>.md`
- `record_id` requirements:
  - ASCII only: `[a-z0-9][a-z0-9-]*`
  - stable (never reuse an ID)
  - recommended pattern: `r-YYYYMMDD-<slug>`

## YAML front matter schema (minimum)

### Required keys

- `id`: string, equals filename without `.md`
- `schema_version`: number, current: `1`
- `type`: one of:
  - `Design` (ideas/specs/reading/plans/pseudocode)
  - `Build` (implementation/integration/refactors/infrastructure changes)
  - `Evaluate` (tests/benchmarks/experiments + analysis)
  - `Decide` (normative decisions: adopt/reject/pivot/change defaults)
- `title`: short human label
- `parents`: list of record IDs (lineage). Use `[]` only for the initial root record.

### Strongly recommended keys

- `status`: short outcome/valence (prefer a small, consistent set)
  - suggested by type:
    - Design: `proposed`, `active`, `archived`
    - Build: `in_progress`, `done`, `reverted`
    - Evaluate: `positive`, `negative`, `inconclusive`
    - Decide: `adopted`, `rejected`, `superseded`
- `tags`: list of short tags
- `created_at`: ISO-8601 timestamp (e.g. `2026-02-28T18:10:00Z`)
- `git` (when applicable):
  - `branch`: string
  - `head`: string (commit sha)
  - `range`: string (e.g. `<base>..<head>`)
  - `stash`: string (e.g. `stash@{0}`)
- `edges`: list of typed links to other records (semantic links; not lineage)
  - item schema: `{ type: <edge_type>, to: <record_id>, note: <optional> }`
  - suggested `edge_type`: `implements`, `tests`, `evaluates`, `supports`, `refines`, `refutes`, `depends_on`, `supersedes`, `produces`, `parallels`

### Optional keys

- `links`: list of external references
  - item schema: `{ kind: <kind>, ref: <string>, note: <optional> }`
  - kinds: `url`, `doi`, `arxiv`, `issue`, `pr`, `paper`
- `artifacts`: list of repo-local artifacts
  - item schema: `{ path: <repo-relative path>, note: <optional> }`
- `metrics`: list of structured metrics (primarily for `Evaluate`)
  - item schema: `{ name: <string>, value: <number|string>, split: <optional>, unit: <optional>, direction: <optional>, baseline: <optional>, note: <optional> }`
  - `direction` suggestions: `higher_better`, `lower_better`, `target`
- `time`: optional structured timing
  - schema: `{ started_at: <optional ISO-8601>, ended_at: <optional ISO-8601> }`
- `opencode`: optional provenance (when git is missing or insufficient)
  - schema: `{ session_id: <string>, message_id: <optional string>, note: <optional string> }`

## Markdown body conventions (keep it short)

### Preferred sections by record type

- Design: `## Intent`, `## Spec`, `## Open questions`, `## Next`
- Build: `## Intent`, `## What changed`, `## Notes`, `## Next`
- Evaluate: `## Intent`, `## Setup`, `## Command`, `## Metrics`, `## Outcome`, `## Notes`
- Decide: `## Decision`, `## Rationale`, `## Consequences`, `## Alternatives considered`

### Writing rules

- Prefer bullets.
- Avoid pasting long diffs or raw logs.
- Do not include secrets.
- If you infer something, label it as inference and attach evidence.
- For any non-trivial claim (especially in `## Outcome` / `## Root cause` / `## Decision`), include at least one evidence hook:
  - git ref/range, command, config path, artifact path, or a link.

## Lineage vs semantic links

- Use `parents` to encode provenance/derivation (the DAG spine). Do not use `parents` for mere chronology.
- Avoid adding `edges` that simply duplicate what `parents` already expresses.
- The DAG visualization uses only lineage edges; semantic `edges` are not rendered as separate arrows (they may be used as hints for edge labels).
- Prefer keeping the graph clean:
  - For `Build`: parent the `Design` plan it implements.
  - For `Evaluate`: parent the `Build` or `Design` record it evaluates.
  - For `Decide`: parent the evidence records used to decide (typically `Evaluate` nodes).
  - For reruns/corrections: parent the record being corrected.

### Guidance by type

- `Decide`:
  - evidence should primarily be listed in `parents`.
  - avoid `edges: supports` back to those same parents unless you need a non-lineage cross-link.
- `Evaluate`:
  - if you include a `Command` block, keep it exact (copy/paste).
  - if the command is unknown, say so explicitly.
  - prefer expressing the evaluation target via `parents`; avoid adding an extra `edges` link unless it is a non-lineage cross-link.
- `Build`:
  - never include placeholder file paths in `apply` mode; omit or ask for the exact paths.

## Minimal templates

Decide

---
id: r-YYYYMMDD-slug
schema_version: 1
type: Decide
title: "..."
parents: [r-...]
status: adopted
tags: [topic]
git:
  branch: "..."
  head: "..."
edges:
  - type: supports
    to: r-...
---

## Decision

- ...

## Rationale

- ...

Evaluate

---
id: r-YYYYMMDD-slug
schema_version: 1
type: Evaluate
title: "..."
parents: [r-...]
status: inconclusive
tags: [topic]
git:
  branch: "..."
  head: "..."
  range: "..."
metrics:
  - name: "..."
    value: 0
---

## Command

```bash
<copy-paste command>
```

## Outcome

- ...
