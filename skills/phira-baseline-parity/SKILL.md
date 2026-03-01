---
name: phira-baseline-parity
description: Checklist for proving baseline behavior is unchanged (or changes are intentional) via controlled A/B runs.
---

Use this skill when implementing a feature that should be opt-in, when defaults must remain identical, or when reviewers ask "did you change baseline behavior?".

This skill is intended to be lazy-loaded on demand: only run parity A/B commands if the researcher approved running them.

Goal: demonstrate parity between baseline and modified code under the same configuration.

## Core principle

If the acceptance criteria does not explicitly change defaults, your implementation should preserve baseline behavior by default.

## Parity checklist

1) Feature gating
- Ensure the new behavior is behind a config/flag.
- Default should match baseline behavior unless the task explicitly changes defaults.

2) Controlled A/B
- Pick one minimal config that exercises the relevant path.
- Run A: baseline behavior (flag off / old path).
- Run B: same config with flag off (in the new codebase) to prove unchanged defaults.
- Run C (optional): flag on to prove the feature does something.

3) Fix confounders
- Same seed(s), same data split, same batch size, same precision settings.
- If determinism is not guaranteed, compare invariants and qualitative traces (e.g., loss decreases, shapes, number of steps, identical config resolution).

4) What to compare (choose what exists)
- Config resolution output / logged hyperparameters
- First-step loss (or first N steps) within tolerance
- Model parameter count / module tree
- Output tensor shapes and dtypes
- Checkpoint metadata

## Reporting (copy/paste)

```
Baseline parity
- Default behavior preserved: <yes/no/unknown>
- Evidence:
  - A/B commands: <commands>
  - Compared: <what you compared>
  - Outcome: <match/tolerance/diff>
- If not preserved: <why + where documented + migration notes>
```
