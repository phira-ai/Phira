{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.phira;
  phiraLib = import ./lib.nix { inherit lib; };
  agents = import ./agents.nix;
  skillsDir = ../skills;
  skillEntries = builtins.readDir skillsDir;
  skillDirs = lib.filterAttrs (_: t: t == "directory") skillEntries;
  renderedAgents = phiraLib.renderAgents {
    inherit agents;
    userAgents = cfg.agents;
  };

  renderedSkills = lib.genAttrs (lib.attrNames skillDirs) (
    name: builtins.readFile (skillsDir + "/${name}/SKILL.md")
  );

  renderedCommands = phiraLib.renderCommands {
    inherit agents;
    userAgents = cfg.agents;
  };

  pluginsDir = ../plugins;
  pluginEntries = builtins.readDir pluginsDir;
  pluginFiles = lib.filterAttrs (_: t: t == "regular") pluginEntries;
  renderedPlugins = lib.genAttrs (lib.attrNames pluginFiles) (
    name: builtins.readFile (pluginsDir + "/${name}")
  );
in
{
  options.programs.phira = {
    enable = lib.mkEnableOption "phira agentic research team";

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      example = {
        pseudocode = {
          agent = {
            settings = {
              model = "openai/gpt-5.3-codex";
              temperature = 0.2;
              color = "accent";
              providersExtra = {
                reasoningEffort = "high";
                textVerbosity = "low";
              };
              extraTools = {
                "context7_*" = true;
                "morph*" = true;
              };
              commands = [
                "plan"
                "review"
              ];
              plugins = [
                "context7"
                "morph"
              ];
            };
            bodySource = ''
              You are the pseudocode assistant.
            '';
          };
          command = {
            settings = {
              description = "Invoke the pseudocode assistant";
              agent = "pseudocode";
              subtask = false;
            };
            bodySource = "Infer the mode from the researcher query and run.";
          };
        };
      };
      description = "Per-agent configuration merged onto the built-in agents. Each entry may set 'enable', 'agent', and 'command'. Use agent.settings.providersExtra for provider-specific keys, agent.settings.extraTools for wildcard MCP tool permissions, and agent.settings.commands/agent.settings.plugins for config passthrough. Both agent.bodySource and command.bodySource accept either a path or a string (including multiline strings).";
    };

    installPath = lib.mkOption {
      type = lib.types.str;
      default = ".config/opencode/agents";
      description = "Home-relative destination for rendered agent markdown files.";
    };

    skillsInstallPath = lib.mkOption {
      type = lib.types.str;
      default = ".config/opencode/skills";
      description = "Home-relative destination for rendered skill directories (each contains SKILL.md).";
    };

    commandsInstallPath = lib.mkOption {
      type = lib.types.str;
      default = ".config/opencode/commands";
      description = "Home-relative destination for command markdown files.";
    };

    pluginsInstallPath = lib.mkOption {
      type = lib.types.str;
      default = ".config/opencode/plugins";
      description = "Home-relative destination for plugin files.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file =
      (lib.mapAttrs' (
        name: text:
        lib.nameValuePair "${cfg.installPath}/${name}.md" {
          source = pkgs.writeText "${name}.md" text;
        }
      ) renderedAgents)
      // (lib.mapAttrs' (
        name: text:
        lib.nameValuePair "${cfg.skillsInstallPath}/${name}/SKILL.md" {
          source = pkgs.writeText "${name}-SKILL.md" text;
        }
      ) renderedSkills)
      // (lib.mapAttrs' (
        name: text:
        lib.nameValuePair "${cfg.commandsInstallPath}/${name}" {
          source = pkgs.writeText name text;
        }
      ) renderedCommands)
      // (lib.mapAttrs' (
        name: text:
        lib.nameValuePair "${cfg.pluginsInstallPath}/${name}" {
          source = pkgs.writeText name text;
        }
      ) renderedPlugins);
  };
}
