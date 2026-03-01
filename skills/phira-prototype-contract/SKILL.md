---
name: phira-prototype-contract
description: Output contract for phira-prototyper (design -> interfaces -> acceptance -> handoff).
---

Use this skill when producing a research prototype design for the Phira team.

## Purpose

- Convert one chosen research direction into a PoC design packet.
- Make it easy for `phira-implementer` to implement.

## Modes

The researcher may specify one of the following mode. If not, infer from the context.

### Mode: concise_pseudocode

Use when the goal is to keep discussion flowing.

Required sections:

1. Goal
2. Interfaces (inputs/outputs/side effects)
3. Data shapes (only the essentials)
4. Verbal pseudocode (short, numbered; include equations when helpful)
5. Edge cases (>= 5)
6. PoC acceptance criteria (pass/fail)
7. Minimal implementation plan (smallest ordered changes)

### Mode: embed_ready_placeholders

Use when the goal is to place navigable pseudocode placeholders alongside the real code.

Required sections:

1. Goal
2. Integration map

- Identify likely hook points (files/functions) and what each placeholder corresponds to.

3. Insertion

- Insert one or more pseudocode placeholder to the hook points.

4. Edge cases (>= 5)
5. PoC acceptance criteria (pass/fail)
6. Minimal implementation plan (smallest ordered changes)

## General rules

- Do not invent repository facts. If you cannot find a hook point, say so and propose a `demo/` or `proto/` location with clear mapping.
