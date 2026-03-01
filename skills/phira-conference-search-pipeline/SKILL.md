---
name: phira-conference-search-pipeline
description: Workflow for conference/venue paper search and short reading lists.
---

Use this skill when the user asks to find relevant papers for an idea/topic, especially within a specific venue (e.g. NeurIPS, ICLR, ICML) or OpenReview.

## Goal

Produce a short, grouped reading list with tight rationales and clear next steps.

## Orchestrator workflow (phira)

1) Clarify constraints (only if needed)
- Venue(s) + year range, or default to the user's most likely venue.
- Topic framing: 1-2 sentences.
- Any must-include seed papers/keywords.

2) Search
- Prefer using an installed venue-aware search skill/tool if available.
  - If the `search-conference` skill is available, load it and follow its procedure instead.
- Otherwise fall back to web search with explicit citations.

3) Rank and group
- Group by theme/mechanism (3-6 groups).
- For each paper: 1-2 sentence rationale and what to look at first.

4) Deliverables
- Reading list.
- 3 concrete "next actions" (what to read next, what to replicate, what to prototype).

