---
name: phira-pseudocode-placeholders
description: Programmatic pseudocode placeholders using a decorator + TYPE_CHECKING blocks (type-checker friendly).
---

Use this skill when embedding pseudocode placeholders into real code files. Attempt to write into files directly.

## Design goals

- Pseudocode lives next to real code for fast navigation.
- Syntax highlighting works (valid Python syntax).
- Runtime behaviour is unchanged (placeholders are never executed or imported).
- Works across type checkers (one-size-fits-all).
- Pseudocode is easily identifiable and replaceable with actual implementaion later.

## Core pattern (Python)

### 1) Always use `TYPE_CHECKING`

- Place BOTH the pseudocode function definition AND any pseudo-call sites under `if TYPE_CHECKING:`.
- This guarantees the placeholder code is not executed at runtime.

### 2) Silence type checkers for the pseudocode body

- Decorate pseudocode functions with `@typing.no_type_check`.
- Use permissive types (`Any`) for pseudocode-only variables.

### 3) Use a decorator for programmatic labelling

Use a shared decorator named `phira_pseudocode`.

- The decorator carries structured metadata (id/title/target/etc.) for later tooling.
- Do NOT redefine the decorator stub in every file.

#### Shared stub package (required)

The shared stub MUST live in a real Python package so it can be imported by any
placeholder-bearing file:

- Package name: `phira_helpers`
- Files:
  - `phira_helpers/__init__.py`
  - `phira_helpers/pseudocode.py` (exports `phira_pseudocode`)

When embedding placeholders:

- Check whether `phira_helpers/pseudocode.py` exists.
- If missing, create the package and module first (minimal, no-op runtime decorator).

##### Template (copy verbatim)

If `phira_helpers/pseudocode.py` does not exist, create it using this exact
template (copy byte-for-byte; do not improvise):

`phira_helpers/__init__.py`

```python
"""Helpers used by Phira scaffolding.

This package is intentionally small and easy to delete once prototypes are
implemented.
"""
```

`phira_helpers/pseudocode.py`

```python
"""Shared pseudocode helpers for Phira placeholder embedding.

This module provides a single decorator, `phira_pseudocode`, used to attach
structured metadata to pseudocode placeholder functions.

It is safe at runtime (no-op) so accidental imports do not break execution.
"""

from __future__ import annotations

from typing import Any, Callable, Mapping, Optional, TypeVar

F = TypeVar("F", bound=Callable[..., object])


def phira_pseudocode(
    *,
    id: str,
    title: str,
    target: Optional[str] = None,  # e.g. "Trainer.compute_loss"
    status: str = "placeholder",
    meta: Optional[Mapping[str, Any]] = None,
    **extra: Any,
) -> Callable[[F], F]:
    """No-op decorator carrying structured metadata.

    The returned decorator attaches the metadata onto the function object under
    `__phira_pseudocode__` for optional downstream tooling.
    """

    payload: dict[str, Any] = {
        "id": id,
        "title": title,
        "target": target,
        "status": status,
        "meta": meta,
    }
    if extra:
        payload.update(extra)

    def decorator(fn: F) -> F:
        try:
            setattr(fn, "__phira_pseudocode__", dict(payload))
        except Exception:
            # Never fail at runtime; metadata is best-effort.
            pass
        return fn

    return decorator
```

### 4) Scope placement (nearest-scope required)

Place each placeholder definition in the smallest enclosing lexical scope of its
`target`.

- If `target` is `SomeClass.some_method`, define `_phira_pseudo_*` inside
  `class SomeClass:` (under `if TYPE_CHECKING:`).
- If `target` is a module-level function, define `_phira_pseudo_*` at module
  level (under `if TYPE_CHECKING:`).

Do not collect placeholders at the top of the script by default.

## Canonical placeholder block

Insert the following pattern. Keep it close to the relevant real hook point.

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from typing import Any, Mapping, no_type_check
    from phira_helpers.pseudocode import phira_pseudocode
```

Example usage:

```python
class Trainer:
    if TYPE_CHECKING:
        @staticmethod
        @no_type_check
        @phira_pseudocode(
            id="loss-foo-v1",
            title="Foo loss (pseudocode placeholder)",
            target="Trainer.compute_loss",
            status="placeholder",
            meta={"notes": "Replace with real implementation"},
        )
        def _phira_pseudo_loss_foo(model: Any, batch: Any) -> float:
            logits = model(batch.inputs)
            targets = batch.targets

            base_loss = cross_entropy(logits, targets)
            penalty = foo_regulariser(logits, targets, alpha=alpha)

            loss = base_loss + penalty
            return float(loss)

# Optional: pseudo-call sites, colocated with the real code they describe.
# Place these exactly where the real call will happen.
# if TYPE_CHECKING:
#     _loss = _phira_pseudo_loss_foo(model, batch)
```

## Naming and metadata

- Function name: `_phira_pseudo_<slug>` (ASCII; searchable).
- `id`: stable identifier for this pseudocode block (ASCII recommended).
- `target`: string naming the intended real hook point.
- `title`: short human label.

## Pseudo-call sites

When you want to show how a pseudocode function is invoked (e.g. inside a training loop), add a pseudo-call site inside the same `if TYPE_CHECKING:` block, placed adjacent to the real code location.

Example:

```python
def train_step(model, batch):
    logits = model(batch.inputs)
    if TYPE_CHECKING:
        # Pseudocode wiring (not executed)
        _loss = _phira_pseudo_loss_foo(model, batch)
    return 0.0
```

## Do not

- Do not redefine `phira_pseudocode` per file; always import from `phira_helpers`.
- Do not define pseudocode placeholders at runtime (keep placeholder defs and pseudo-call sites under `TYPE_CHECKING`).
- Do not use per-tool ignore pragmas unless unavoidable (`# type: ignore[...]`) since they are checker-specific.
