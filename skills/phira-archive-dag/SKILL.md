---
name: phira-archive-dag
description: Deterministic Graphviz/DOT derivation + validation for archive records.
---

Use this skill when regenerating `.archive/graph.dot`.

## Goal

- `.archive/graph.dot` must be deterministically derivable from `.archive/records/*.md`.
- Derivation must fail closed when the archive is ill-formed.

## Inputs

- Record files: `.archive/records/*.md`
- Pointer files: `.archive/pointers/*.yaml` and `.archive/pointers/branches/*.yaml`

## Validation (fail closed)

Derivation MUST fail if any of the following are true:

- A record file is missing YAML front matter.
- YAML front matter does not parse.
- Required keys missing: `id`, `schema_version`, `type`, `title`, `parents`.
- `schema_version` is not `1`.
- `id` does not match filename.
- `id` does not match `[a-z0-9][a-z0-9-]*`.
- `type` is not one of: `Design`, `Build`, `Evaluate`, `Decide`.
- Duplicate record IDs.
- `parents` references a non-existent record ID.
- The `parents` graph contains a cycle.
- A pointer references a non-existent record ID.
- Any `edges[*].to` references a non-existent record ID.

## Warnings (do not fail derivation)

- Missing optional fields (`status`, `tags`, `git`, `metrics`).
- Unknown `edges[*].type` (ignore unless used as a hint).

## DOT output rules (deterministic)

- Always generate a single DOT file:
  - path: `.archive/graph.dot`
  - graph name: `phira_archive`
- Determinism:
  - sort nodes by `id` ascending
  - sort parent edges by `(from,to)`
  - sort lineage edge labels deterministically (token sort + `|` join)

### Graph structure

- Use `digraph phira_archive { ... }`.
- Set global defaults:
  - `rankdir=LR`
  - `concentrate=true`
  - `node [fontname="Helvetica", shape="box", style="rounded,filled", fillcolor="white", color="gray30"]`
  - `edge [fontname="Helvetica", color="gray40"]`

### Node labeling

- Node id is the record `id`.
- Label should be compact and stable:
  - `label = "<id>\n<type>\n<title>"`
- Optional: append `status` on its own line if present.

### Type styling (suggested)

- Design: shape=folder, fillcolor="#f0f0f0"
- Build: shape=box, fillcolor="#e8f4ff"
- Evaluate: shape=component, fillcolor="#eaffea"
- Decide: shape=box, fillcolor="#fff7cc"

### Edges

Only draw ONE directed edge between records: the lineage edge from `parent -> child`.

- Do not render a separate semantic-edge layer.
- Instead, attach a short label to the lineage edge.

This avoids duplicate/opposing arrows and keeps the DAG readable.

#### Lineage edge emission

For each `parent` in `parents`, emit exactly:

`"<parent>" -> "<id>" [label="<edge_label>", weight=2, penwidth=1.5]`

#### Edge label computation (deterministic)

Compute `edge_label` for the lineage edge `parent -> child` as follows:

1) Collect semantic hints from YAML `edges` across all records.

- If there exists any semantic `edges` relationship connecting `child` and `parent` (in either direction), convert those to one or more lineage label tokens.
- If one or more tokens exist, use them (sorted, joined with `|`) as the lineage edge label.

2) Otherwise, fall back to a type-based default label:

- `Design -> Build`: `implemented_by`
- `Build -> Evaluate`: `evaluated_by`
- `Evaluate -> Decide`: `supports`
- `Evaluate -> Evaluate`: `refined_by`
- `Decide -> Decide`: `superseded_by`
- fallback: `derives`

#### Semantic-hint mapping

Map semantic edge types to lineage label tokens, relative to the lineage direction `parent -> child`:

- If semantic edge is `child -> parent`:
  - `implements` => `implemented_by`
  - `tests` => `evaluated_by`
  - `evaluates` => `evaluated_by`
  - `refines` => `refined_by`
  - `supersedes` => `superseded_by`
  - `depends_on` => `required_by`
- If semantic edge is `parent -> child`:
  - `produces` => `produces`

If multiple semantic hints apply, sort the resulting tokens and join with `|`.

### Pointers in the graph

- Do not add pointer nodes.
- Include a short comment header listing resolved pointer head(s) (record IDs).

## Error reporting

- On failure, report:
  - which file
  - what key/path is invalid
  - the smallest concrete fix (rename id, add missing field, correct reference)
