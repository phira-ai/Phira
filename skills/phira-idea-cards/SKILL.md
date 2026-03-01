---
name: phira-idea-cards
description: Option-card format for phira-hypothesizer (math-first ideas + end-to-end training/inference).
---

Use this skill when generating research directions for the Phira team.

## Purpose

- Convert vague goals (or paper-derived mechanisms) into multiple actionable directions.
- Ensure each direction is internally consistent and can be handed to `phira-prototyper`.

## Required output (option cards)

Produce 3-5 option cards. Each card MUST include:

1) Title + one-line thesis

2) Core mechanism (math-first)

- Define symbols before first use.
- Include the objective and/or update rules when applicable.
- State key assumptions explicitly.

3) Training pipeline (end-to-end)

- Data: inputs, preprocessing, split protocol, leakage risks.
- Model: modules/interfaces; key shapes if relevant.
- Objective: losses/regularisers/constraints; weighting.
- Optimisation: optimiser/schedule/stability tricks; any distributed/precision assumptions.
- Outputs: checkpoints, logs, metrics, artefacts.

4) Inference pipeline (end-to-end)

- Inputs/outputs; runtime steps (retrieval/decoding/postprocessing if any).
- Calibration/uncertainty or failure handling assumptions if relevant.

5) Failure modes and tradeoffs (ranked)

6) Validation hooks (light)

- 1-3 quick checks that would confirm the direction is implemented/plumbed correctly.
- Avoid long experiment plans.

## Recommendation + handoff

End with:

- A recommended option and the criteria used.
- A handoff packet for prototyping: the minimal interfaces and unknowns to resolve.

## Notation rules

- $\mathcal{C}$ denotes a set.
- Bold lowercase $\mathbf{x}$ denotes a vector; bold uppercase $\mathbf{X}$ denotes a matrix.
- Uppercase $X$ denotes a random variable; lowercase $x$ denotes a deterministic value.
- Use $...$ for inline maths and $$...$$ for display maths.
