---
name: phira-impl-vs-claim-audit
description: Procedure to audit alignment between a document's claims (e.g., algorithm description) and the actual implementation and defaults.
---

Use this skill when someone provides a document describing what was implemented (paper, design doc, README section, notes) and you need to check whether the code actually matches what the document claims.

Goal: detect "claim drift" (code does not implement the described algorithm/behavior) and "default drift" (defaults/baseline behavior changed unintentionally).

## Inputs you should request (if missing)

- The document excerpt(s): exact text, with section headings (and page/figure/equation numbers if applicable).
- Implementation context: changed files/diff, new flags/config keys, and the intended entrypoint(s).
- Any stated compatibility constraints (env versions, dependency policy).

## Audit checklist

1) Extract and restate the document claims
- Pull out 3-10 testable claims from the document.
- Separate:
  - Algorithmic steps ("do A then B")
  - Definitions (symbols, losses, schedules)
  - Defaults (what happens if no flags are set)
  - Expected outputs/logs/metrics
- Restate each claim in one sentence, testable language.

2) Map document -> code
- For each extracted claim, identify:
  - where it is implemented (file + symbol)
  - how it is triggered (config/flag/entrypoint)
  - what the default does
  - what is intentionally omitted or approximated (if any)

3) Default drift
- Verify new code paths are gated when they should be.
- Verify default config values preserve baseline behavior unless explicitly changed.

If the document describes a new algorithm but the feature is intended to be opt-in, explicitly confirm the gating and defaults.

4) Evidence quality (did we actually test the claim?)
- Check whether any reported commands actually exercise the described algorithm path.
- Prefer evidence that would fail if the algorithm were not implemented (assertions, characteristic logs, shape/value invariants).

If there is no evidence, propose the smallest decisive check(s): a tiny run, a unit test, or a "print the computed term" invariant.

5) Algorithmic fidelity traps
- Look for the common mismatches between docs and code:
  - wrong loss term sign/scaling/normalization
  - missing detach/stop-gradient
  - schedule differs (warmup, EMA, anneal)
  - sampling differs (teacher forcing vs free running, masking)
  - batch reduction differs (mean vs sum)
  - randomness/seed placement differs

6) Integration seams
- Look for the classic breakpoints: config plumbing, checkpoint load/save, distributed wrappers, dtype/device moves, shape conventions.

## Required output (table)

Return a table like this:

```
Doc claim (with citation) -> Implementation (file:symbol + gate/default) -> Evidence -> Risk / Mismatch
- <claim 1 @ section/page/eq> -> <where + how enabled + default> -> <command/log/assertion or "none"> -> <mismatch or remaining risk>
- <claim 2 @ ...> -> ...
```

End with:
- Verdict: PASS | FAIL
- Smallest fix list (if FAIL)
