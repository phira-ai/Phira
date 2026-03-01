# phira

> _A supervised agentic team for Machine Learning and Computer Science research._

Modern AI research is all about fast iteration: you test and discard ideas rapidly until you find the signal.

`phira` is a multi-agent reasearch assistant team designed to help you keep up.
It is inspired by the simple `Plan/Build` modes found in many AI coding tools, but extends and tailors that concept explicitly for the complexities of research.

> [!NOTE]
> While autonomous "AI scientists" (like [**AI4AI**](https://analemma.ai/fars/)) might be the future, `phira` takes a step back. At the end of the day, you are the researcher who is behind the wheel. `phira` handles the other things so you can focus on the ideas.

---

## Table of contents

- [Install](#install)
  - [Manual installation (release ZIP)](#manual-installation-release-zip)
  - [Nix Home-Manager (optional)](#nix-home-manager-optional)
- [Design choices](#design-choices)
- [Team architecture](#team-architecture)
  - [The Roles](#the-roles)
- [Workflows](#workflows)
  - [How to use](#how-to-use)
  - [When to run archivist manually](#when-to-run-archivist-manually)
  - [Typical Tasks](#typical-tasks)
- [Skills (Contracts)](#skills-contracts)

## Install

### Manual installation (release ZIP)

Download the package from Releases and follow [INSTALL.md](INSTALL.md).

If you are using OpenCode directly, you can ask your agent to install `phira` for you:

Paste this into OpenCode:

```text
Install Phira for me by following INSTALL.md in this repository exactly.

Use:
- Release page: https://github.com/phira-ai/Phira/releases
- Asset name pattern: phira-opencode-<tag>.zip
- Install path: ~/.config/opencode/phira

After install, verify:
1) phira agents exist under ~/.config/opencode/agents
2) /p /h /i /r /a commands exist under ~/.config/opencode/commands
3) phira-* skills exist under ~/.config/opencode/skills
4) archivist-auto.js exists under ~/.config/opencode/plugins
```

Then restart OpenCode to apply change.

### Nix Home-Manager (optional)

If you prefer Nix-managed installs, add this repo as a flake input and enable the module:

```nix
{
  inputs.phira = {
    url = "github:phira-ai/Phira";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, home-manager, phira, ... }: {
    homeConfigurations."<you>" = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "<your-system>"; };
      modules = [
        phira.homeManagerModules.default
        ({ ... }: {
          programs.phira.enable = true;

          # Optional overrides:
          # programs.phira.agents = { phira = { settings = { model = "..."; }; }; };
        })
      ];
    };
  };
}
```

## Design choices

Most coding agents are monolithic: you ask for a feature, and they start editing your codebase. They often guess at interfaces, assume constraints, and overwrite your pipelines.

`phira` uses a different model based on these principles:

1. **Separation of concerns:** Ideation, Prototyping, Implementation, and Verification are distinct tasks handled by distinct, tightly-scoped agents.
2. **Researcher in control:** Invoke agents via commands `/` or subagents `@`. Or, let `phira` decides the delegation for you (experimental).
3. **Falsifiability by default:** Ideas require failure modes. Prototypes require acceptance criteria. Implementations must pass an independent agent's review before being presented to you.
4. **Durable memory:** Built-in per-project memory system. Experiments and decisions are recorded in a parseable archive graph next to your code, rather than lost in a chat history.
5. **No hallucinated facts:** When agents read a paper or codebase, they are instructed to cite their sources (page, figure, line number) or explicitly say "Not stated."

---

## Team architecture

```
                               ┌───────────────┐
                               │     phira     │
                               │ (orchestrator)│
                               └───────┬───────┘
                                       │
       ┌───────────────┬───────────────┴───────────────┬───────────────┐
       ▼               ▼               ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│ Prototyper  │ │Hypothesizer │ │ Implementer │ │ Reviewer-2  │ │  Archivist  │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
```

### The Roles

- 🧭 **`phira` (Orchestrator)**
  The manager. Answers general research-related questions. Interprets your intent, proposes plan on which agent should do what, complete tasks autonomously (experimental).

- 🧩 **`phira-prototyper` **(Design & scaffolding)\*\*
  Takes a chosen direction and turns it into a Proof-of-Concept design with formal interfaces and edge cases. See how the ideas look like next to your real code

- 🧠 **`phira-hypothesizer` **(Idea formation)\*\*
  Turns vague directions into 3-5 distinct option cards. It focuses on math-forward core mechanisms and end-to-end training/inference pipelines rather than just prose.

- 🛠️ **`phira-implementer` (Implementation)**
  The builder that implements everything you asks.

- 🔍 **`phira-reviewer-2` (Verification)**
  The independent critic. It challenges ideas by default. It verifies implementations with hard PASS/FAIL evidence.

- 🗂️ **`phira-archivist` (Bookkeeping)**
  Proposes durable updates for your project's memory. It maintains a clean, append-only Directed Acyclic Graph (DAG) of what was tried and why.

---

## Workflows

If you want the agents to take in your current chat history as their context, invoke them using commands:
| Agent | Command |
|-------|---------|
|Prototyper|`/p`|
|Hypothesizer|`/h`|
|Implementer|`/i`|
|Reviewer-2|`/r`|
|Archivist|`/a`|

Alternatively, if you don't want the agents to pollute or to be polluted by your chat history, you can invoke them as subagents with `@`

### How to use

Use this simple workflow for new ideas:

1. **Brainstorm and challenge in parallel**
   Ask `phira-hypothesizer` to generate options, and ask `phira-reviewer-2` to challenge them.

2. **Prototype in words first**
   Ask `phira-prototyper` for verbal pseudocode, interfaces, edge cases, and clear pass/fail criteria.

3. **Inject placeholders into target files**
   Ask `phira-prototyper` to add pseudocode scaffolds at the real hook points.
   Review the scaffolds before implementation.

4. **Implement**
   Ask `phira-implementer` to turn the scaffolds into runtime code.

5. **Archive**
   When implementation is done, `phira-archivist` logs the outcome as a durable record.

### When to run archivist manually

You can run `phira-archivist` (`/a`) any time, especially after:

- Evaluating a new implementation or experiment.
- Deciding to abandon one direction.
- Choosing one candidate among multiple implementations.
- Reading new papers and recording high-signal takeaways.

### Typical Tasks

> [Warning]
> Works best with [`summarise-paper`](https://github.com/phira-ai/Phi-Skills.git) and [`search-conference`](https://github.com/phira-ai/Phi-Skills.git) skills.

- **Paper Summarisation:**
  You provide an arXiv link or a PDF file. `phira` orchestrates downloading the TeX source or rendering the PDF. The hypothesizer drafts a note. Reviewer-2 audits it for faithfulness and adds a "limitations and threats" section. `phira` organises and writes the note to a TeX file, and the archivist logs it.

- **Conference / Venue Paper Search:**
  You provide a topic framing (1-2 sentences), with optional venue/year constraints and seed papers. `phira` retrieves with `search-conference` when available, then ranks and groups papers by theme. The output is a short reading list with per-paper rationales, "what to read first" pointers, and 3 concrete next actions.

---

## Skills (Contracts)

The glue that holds this team together is a library of "Skills"—strict contracts that define exactly what data is passed around.
See the local [Skills Ownership Map](skills/README.md) for agent-to-skill ownership and collaboration.
