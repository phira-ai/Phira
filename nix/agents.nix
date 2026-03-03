{
  phira = {
    enable = true;
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

  phira-prototyper = {
    enable = true;
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

  phira-hypothesizer = {
    enable = true;
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

  phira-implementer = {
    enable = true;
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

  phira-reviewer-2 = {
    enable = true;
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

  phira-archivist = {
    enable = true;
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
}
