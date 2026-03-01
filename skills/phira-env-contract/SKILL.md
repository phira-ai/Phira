---
name: phira-env-contract
description: Procedural checklist to infer and state the repo's effective runtime environment and dependency policy.
---

Use this skill whenever you are about to implement code that could be sensitive to Python/library versions, GPU/CPU availability, or dependency policy.

Goal: produce an explicit "environment contract" that constrains implementation choices and makes later failures reproducible.

## Output (copy/paste into your response)

Provide this block near the top of your implementation report:

```
Environment contract
- Python: <version or "unknown">
- Platform: <os/arch or "unknown">
- Key deps: <package>=<version> (only those that matter)
- Dependency policy: <"no new deps" | "deps allowed" | "unknown">
- Hardware: <"cpu" | "gpu" | "unknown"> (only if relevant)
- Provenance: <how you inferred this>
```

## Checklist (do in order)

1) Prefer repo artifacts over assumptions
- Look for: `pyproject.toml`, `requirements*.txt`, `poetry.lock`, `uv.lock`, `Pipfile.lock`, `environment.yml`, `conda*.yml`, `Dockerfile`, `docker-compose.yml`, `Makefile`, `noxfile.py`, `tox.ini`, `.python-version`, `.tool-versions`, `setup.cfg`, `setup.py`.
- Look for CI: `.github/workflows/**`, `ci/**`.
- Look for runtime docs: `README*`, `docs/**`.

2) Infer Python version
- If `.python-version` / `.tool-versions` exists: trust it.
- Else if CI pins Python: trust CI.
- Else if Dockerfile pins Python: trust Docker.
- Else: report as `unknown` and constrain implementation to broadly compatible code.

3) Identify the smallest set of "key deps"
- Only list packages that affect your change (e.g., `torch`, `jax`, `transformers`, `numpy`, `pydantic`, `hydra`, `lightning`, `accelerate`, `datasets`).
- Prefer pinned lockfiles over loose requirements.

4) Determine dependency policy
- If the task explicitly allows new deps: set `deps allowed`.
- Else default to `no new deps`.
- If you truly cannot infer: mark `unknown` and stop to ask `phira` only if it changes the implementation approach.

5) Record provenance
- Cite exactly which artifacts/commands you used (e.g., "from `.github/workflows/ci.yml`", "from `pyproject.toml`", "ran `python --version` in this env").

## Guardrails

- If environment constraints are unknown and materially affect correctness, ask `phira` one targeted question that requests only the missing constraint(s).
- Do not upgrade/bump dependencies by default.
