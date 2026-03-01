---
name: phira-paper-summary-pipeline
description: How Phira roles collaborate to summarise papers and archive outcomes.
---

Use this skill when the user asks to summarise one or more research papers.

You MUST load and follow the `summarise-paper` skill.

## High-level contract

- `phira` orchestrates and does the heavy lifting (PDF->images, arXiv source download/unpack).
- `phira-hypothesizer` drafts the main note content (faithful, cited, math-aware) but does not write files.
- `phira-reviewer-2` is used both:
  - as a parallel specialist to independently draft limitations/threats-to-validity/questions, and
  - as a later gate to audit faithfulness/integrity of the merged note.
- The final note is written by `phira` into files directly.
- `phira-archivist` produces a concise bookkeeping record.

## Storage convention (recommended)

- Paper notes live under: `note/<paper_slug>/main.tex`
- `paper_slug` should be stable and ASCII:
  - Prefer `arxiv-<id>` for arXiv papers (e.g. `arxiv-2601.07372`)
  - Otherwise: `authorYYYY-short-title`

## Orchestrator heavy lifting (phira)

1. Determine input type

- PDF file path: render page images under `.cache/<paper_slug>/[1..N].png`.
- arXiv URL: download TeX source to `.cache/downloads/<paper_slug>/`, unpack into `.cache/<paper_slug>/`, locate entry tex file.

2. Provide context packet to subagents

- Source pointers: the cache directory, plus any user focus (methodology vs experiments vs transferability).
- Note target: `note/<paper_slug>/main.tex`.

3. Ensure governing constraints are explicit

- Faithfulness: "Not stated in the paper" when missing.
- Cite section/figure/table/equation/page where possible.
- British English if required.

## Hypothesizer responsibilities

- Read the provided sources (PDF images or TeX source).
- Produce a draft note in the requested structure (typically the `summarise-paper` skill structure).
- Do not invent results; attach citations for key claims.
- Return the draft to `phira` for onward routing.

## Reviewer-2 responsibilities

- Stage A (parallel limitations package):
  - Read the provided sources (PDF images or TeX source)
  - Independently produce the limitations content:
    - Strengths, weaknesses/risks, threats to validity/confounders.
    - "What I would ask the authors as a reviewer" (2-3 questions).
  - Return to `phira` as a standalone limitations section.

- Stage B (gate audit):
  - Audit the merged note draft against the source.
  - Provide corrections as concrete edits.
  - Re-check that limitations are accurate and not hallucinated.
  - Return audit verdict + required fixes to `phira`.

## Archivist responsibilities

- load and follow skills:
  - `phira-archive-dag`
  - `phira-archive-format`
  - `phira-archive-pointers`
- Create a concise archive record capturing:
  - Paper identity (url/arXiv id/doi if known)
  - Where the note lives (`note/<paper_slug>/main.tex`)
  - High-signal takeaways (what to steal, what to be cautious about)
  - Any decisions made or follow-up ideas
- directly write the records into the archive directory, update the pointer, and update the graph
