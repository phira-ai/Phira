{
  phira = {
    enable = true;
    agent = {
      settings = {
        description = "Primary orchestrator for the Phira team. Supervises progress; never edits repo files.";
        model = "openai/gpt-5.2";
        mode = "primary";
        temperature = 0.2;
        color = "#d2ccff";
        providersExtra = {
          reasoningEffort = "high";
          textVerbosity = "low";
        };
        permission = {
          edit = "allow";
          bash = "allow";
          task = {
            "*" = "deny";
            "explore" = "allow";
            "phira-*" = "allow";
          };
        };
        tools = {
          "*" = true;
        };
      };
      bodySource = ../prompts/phira.md;
    };
  };

  phira-prototyper = {
    enable = true;
    agent = {
      settings = {
        description = "Prototyping role for Phira. Produces pseudocode, helps for building PoC.";
        model = "openai/gpt-5.3-codex";
        mode = "subagent";
        hidden = false;
        temperature = 0.0;
        providersExtra = {
          reasoningEffort = "high";
          textVerbosity = "low";
        };
        permission = {
          edit = "allow";
          bash = "allow";
          task = "deny";
        };
        tools = {
          "*" = true;
          task = false;
        };
      };
      bodySource = ../prompts/phira-prototyper.md;
    };
    command = {
      fileName = "p.md";
      settings = {
        description = "Invoke the Prototyper agent";
        agent = "phira-prototyper";
        subtask = false;
      };
      bodySource = ''
        Infer for approriate mode (concise_pseudocode, embed_ready_placeholders) from the researcher's query and the current context, load suitable skills to accomplish the job.
      '';
    };
  };

  phira-hypothesizer = {
    enable = true;
    agent = {
      settings = {
        description = "Ideation and brainstorming role for Phira. Generates actionale idea.";
        model = "openai/gpt-5.2";
        providersExtra = {
          reasoningEffort = "high";
          textVerbosity = "medium";
        };
        mode = "subagent";
        temperature = 0.8;
        hidden = false;
        permission = {
          edit = "deny";
          bash = "deny";
          task = "deny";
        };
        tools = {
          "*" = false;
          glob = true;
          grep = true;
          question = true;
          read = true;
          skill = true;
          webfetch = true;
          websearch = true;
          google_search = true;
          codesearch = true;
        };
        extraTools = {
          "context7_*" = true;
          "morph*" = true;
        };
      };
      bodySource = ../prompts/phira-hypothesizer.md;
    };
    command = {
      fileName = "h.md";
      settings = {
        description = "Invoke the Hypothesizer agent";
        agent = "phira-hypothesizer";
        subtask = false;
      };
      bodySource = ''
        Infer the appropriate mode (idea formation, brainstorm from goal, paper discussion, paper summarisation, revision from reviewer feedback) from the researcher's query and answer with the corresponding output format.

        If reviewer feedback is present in context (especially a `for_hypothesizer` block), switch to revision mode and:

        - explicitly list the reviewer item IDs you are addressing,
        - include a feedback resolution matrix (`feedback_id`, `action`, `change_made`, `rationale`),
        - and list unresolved items with next actions.

        Revision mode default is incremental: revise existing option cards by ID/title and avoid regenerating a full 3-5 card set unless reviewer feedback blocks the core premise, the user requests regeneration, or prior cards are unavailable.
      '';
    };
  };

  phira-implementer = {
    enable = true;
    agent = {
      settings = {
        description = "Implementation role for Phira. Implement ideas and actions into code.";
        model = "openai/gpt-5.3-codex";
        providersExtra = {
          reasoningEffort = "high";
          textVerbosity = "low";
        };
        mode = "subagent";
        temperature = 0.0;
        hidden = false;
        permission = {
          bash = "allow";
          edit = {
            "*" = "ask";
            ".archive/**" = "deny";
          };
          task = "deny";
        };
        tools = {
          "*" = true;
          task = false;
        };
      };
      bodySource = ../prompts/phira-implementer.md;
    };
    command = {
      fileName = "i.md";
      settings = {
        description = "Invoke the Implementer agent";
        agent = "phira-implementer";
        subtask = false;
      };
      bodySource = ''
        Infer for approriate mode (standard implementation, or from pseudocode) from the researcher's query and the current context, load suitable skills to accomplish the job.

        Always include the implementer `archive_handoff` machine-readable YAML block in the final output.

        Auto-archive integration:

        - Use command arg `noarchive` to opt out of the *external* auto-archive trigger for a specific run.
      '';
    };
  };

  phira-reviewer-2 = {
    enable = true;
    agent = {
      settings = {
        description = "Critic role for Phira. Independently examines the ideas and implementation critically.";
        model = "openai/gpt-5.2";
        mode = "subagent";
        temperature = 0.0;
        hidden = false;
        providersExtra = {
          reasoningEffort = "high";
          textVerbosity = "low";
        };
        permission = {
          bash = "allow";
          edit = "deny";
          task = "deny";
        };
        tools = {
          "*" = false;
          bash = true;
          question = true;
          read = true;
          glob = true;
          grep = true;
          skill = true;
          webfetch = true;
          websearch = true;
          google_search = true;
        };
        extraTools = {
          "context7_*" = true;
          "morph*" = true;
        };
      };
      bodySource = ../prompts/phira-reviewer-2.md;
    };
    command = {
      fileName = "r.md";
      settings = {
        description = "Invoke the Reviewer agent";
        agent = "phira-reviewer-2";
        subtask = false;
      };
      bodySource = ''
        Infer the intent from the researcher's query and answer with the corresponding output format.

        When the review is intended to feed `phira-hypothesizer`, end your response with a `for_hypothesizer` YAML block that includes:

        - `verdict`
        - `must_fix[]`
        - `should_fix[]`
        - `open_questions[]`
        - `evidence_needed[]`

        Keep each item concise, actionable, and ID-tagged (for example `R1`, `S1`, `Q1`, `E1`).
      '';
    };
  };

  phira-archivist = {
    enable = true;
    agent = {
      settings = {
        description = "Bookkeeping role for Phira. Proposes updates to persistent memory.";
        model = "openai/gpt-5.3-codex";
        mode = "subagent";
        temperature = 0.0;
        hidden = false;
        providersExtra = {
          reasoningEffort = "low";
          textVerbosity = "low";
        };
        permission = {
          edit = "allow";
          bash = "allow";
          task = "deny";
        };
        tools = {
          "*" = true;
          task = false;
        };
      };
      bodySource = ../prompts/phira-archivist.md;
    };
    command = {
      fileName = "a.md";
      settings = {
        description = "Invoke the Archivist agent";
        agent = "phira-archivist";
        subtask = false;
      };
      bodySource = ''
        Infer the intent and mode from the researcher's query and the current context:

        - Default to `draft` (no writes).
        - Use `apply` only when the researcher explicitly asks to write/update the archive (e.g. "apply", "write", "log this").
        - Use `brief` when the researcher asks for a status briefing without updating files.

        Follow the archive skills:

        - `phira-archive-format`
        - `phira-archive-pointers`
        - `phira-archive-dag`

        Hard constraints:

        - Only write under `.archive/**`.
        - No hallucinations and no secrets.
      '';
    };
  };
}
