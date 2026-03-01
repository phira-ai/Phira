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

  commandsDir = ../commands;
  commandEntries = builtins.readDir commandsDir;
  commandFiles = lib.filterAttrs (_: t: t == "regular") commandEntries;
  renderedCommands = lib.genAttrs (lib.attrNames commandFiles) (
    name: builtins.readFile (commandsDir + "/${name}")
  );

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
        };
      };
      description = "Per-agent configuration merged onto the built-in agents. Each agent may set 'enable', 'settings', and 'bodySource'. Use settings.providersExtra for provider-specific keys, settings.extraTools for wildcard MCP tool permissions, and settings.commands/settings.plugins for command/plugin config passthrough.";
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
