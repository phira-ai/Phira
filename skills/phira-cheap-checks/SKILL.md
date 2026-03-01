---
name: phira-cheap-checks
description: Fast, compute-aware verification checklist for implementation changes (imports, configs, tiny runs).
---

Use this skill after making changes, before claiming success.

This skill is intended to be lazy-loaded on demand: only run the checks if the researcher approved running commands/compute.

Goal: produce evidence that the change is wired correctly and does not break the pipeline, without requiring long training.

## Selection rule

Pick the strongest checks you can run within the budget you have. Prefer existing project commands over inventing new ones.

## Cheap check menu (choose a few)

1) Static / import sanity
- `python -m compileall <package_or_paths>`
- `python -c "import <top_level_pkg>"`
- Run the project's linters/typecheckers if they exist and are cheap.

2) Config / CLI parsing
- Run the main entrypoint with `--help`.
- Load the config(s) you touched and ensure overrides resolve.
- If the repo has a config validation command, run it.

3) Unit tests (if present)
- Run the smallest relevant subset.
- Prefer: `pytest -k <keyword>` / `python -m pytest <path>`.

4) Tiny smoke run
- 1-10 steps on CPU if possible.
- Assert the new code path is exercised (log line, counter, or explicit assertion).
- If the repo supports a tiny dataset or synthetic mode, use it.

5) Serialization / checkpoint sanity (only if relevant)
- Ensure the new module/state can be saved/loaded.
- If checkpoints include config hashes, verify they still compute.

## Reporting (copy/paste)

In your "Commands run + results" section, report each check as:

```
- <command>
  - Result: <pass/fail>
  - Key output: <1-3 lines that prove it>
```

## If you cannot run checks

Say so explicitly, then provide:
- the exact command(s) you would run with adequate compute
- what success would look like
- the smallest manual verification steps
