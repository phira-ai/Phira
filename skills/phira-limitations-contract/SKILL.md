---
name: phira-limitations-contract
description: Standard format for limitations, threats-to-validity, and critical risks with decisive tests.
---

Use this skill whenever you are producing or reviewing limitations for:

- a paper summary
- a research plan
- an implementation
- an experiment/evaluation

## Output contract

Always produce a "Limitations" section with 5-12 items.

Each item MUST include:

- Limitation: one sentence.
- Why it matters: one sentence.
- Severity: `Block` | `Risky` | `Minor`.
- Decisive test: the smallest test/experiment/check that would validate or falsify the concern.
- Mitigation or acceptance condition: what change (or explicit acceptance) would resolve it.

## Paper-specific requirements

Include (if applicable):

- dataset/evaluation threats (leakage, selection bias, confounding)
- generalisation/robustness gaps
- compute/budget comparability
- missing ablations / baseline fairness
- unclear assumptions or underspecified details

## Implementation-specific requirements

Include (if applicable):

- default drift / gating risk
- reproducibility risks (seeds, versions, configs)
- silent failure modes and missing invariants
- performance regressions and measurement pitfalls
