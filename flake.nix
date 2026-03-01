{
  description = "phira OpenCode agents, skills, commands, and plugins";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      homeManagerModules.default = import ./nix/hm-module.nix;

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          phiRaLib = import ./nix/lib.nix { lib = pkgs.lib; };
          agentDefs = import ./nix/agents.nix;
          renderedAgents = phiRaLib.renderAgents {
            agents = agentDefs;
            userAgents = { };
          };
          files = pkgs.lib.mapAttrsToList (
            name: text: pkgs.writeTextDir "agents/${name}.md" text
          ) renderedAgents;

          skillsDir = ./skills;
          skillEntries = builtins.readDir skillsDir;
          skillDirs = pkgs.lib.filterAttrs (_: t: t == "directory") skillEntries;
          skillFiles = map (
            name: pkgs.writeTextDir "skills/${name}/SKILL.md" (builtins.readFile (skillsDir + "/${name}/SKILL.md"))
          ) (pkgs.lib.attrNames skillDirs);

          commandsDir = ./commands;
          commandEntries = builtins.readDir commandsDir;
          commandFiles = pkgs.lib.filterAttrs (_: t: t == "regular") commandEntries;
          renderedCommandFiles = map (
            name: pkgs.writeTextDir "commands/${name}" (builtins.readFile (commandsDir + "/${name}"))
          ) (pkgs.lib.attrNames commandFiles);

          pluginsDir = ./plugins;
          pluginEntries = builtins.readDir pluginsDir;
          pluginFiles = pkgs.lib.filterAttrs (_: t: t == "regular") pluginEntries;
          renderedPluginFiles = map (
            name: pkgs.writeTextDir "plugins/${name}" (builtins.readFile (pluginsDir + "/${name}"))
          ) (pkgs.lib.attrNames pluginFiles);
        in
        {
          phira = pkgs.symlinkJoin {
            name = "phira";
            paths = files ++ skillFiles ++ renderedCommandFiles ++ renderedPluginFiles;
          };
        }
      );
    };
}
