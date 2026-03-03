{ lib }:
let
  toYamlScalar = value: builtins.toJSON value;

  renderBodySource = bodySource:
    if builtins.isPath bodySource then
      builtins.readFile bodySource
    else if builtins.isString bodySource then
      bodySource
    else
      throw "bodySource must be a path or string";

  formatKey = key:
    if builtins.match "^[A-Za-z0-9_-]+$" key != null then
      key
    else
      "\"${lib.replaceStrings [ "\"" ] [ "\\\"" ] key}\"";

  renderYaml =
    indent: attrs:
    lib.concatStringsSep "\n" (
      map (
        name:
        let
          value = attrs.${name};
        in
        if builtins.isAttrs value then
          "${indent}${formatKey name}:\n${renderYaml "${indent}  " value}"
        else
          "${indent}${formatKey name}: ${toYamlScalar value}"
      ) (lib.attrNames attrs)
    );

  renderFrontmatter = settings: ''
    ---
    ${renderYaml "" settings}
    ---
  '';

  renderAgent = agent: ''
    ${
      let
        agentCfg = if agent ? agent then agent.agent else agent;
        settings0 =
          if agentCfg ? settings then
            agentCfg.settings
          else if agent ? settings then
            agent.settings
          else
            { };
        providersExtra =
          if settings0 ? providersExtra then
            settings0.providersExtra
          else
            { };
        extraTools =
          if settings0 ? extraTools then
            settings0.extraTools
          else
            { };
        baseSettings = lib.removeAttrs settings0 [
          "providersExtra"
          "extraTools"
        ];
        effectiveSettings0 = lib.recursiveUpdate providersExtra baseSettings;
        effectiveSettings =
          if extraTools == { } then
            effectiveSettings0
          else
            let
              mergedTools = lib.recursiveUpdate extraTools (effectiveSettings0.tools or { });
            in
            effectiveSettings0 // { tools = mergedTools; };
      in
      renderFrontmatter effectiveSettings
    }

    ${
      let
        agentCfg = if agent ? agent then agent.agent else agent;
        bodySource =
          if agentCfg ? bodySource then
            agentCfg.bodySource
          else if agent ? bodySource then
            agent.bodySource
          else
            "";
      in
      renderBodySource bodySource
    }
  '';

  renderCommand = command: ''
    ${
      let
        commandCfg = if command ? command then command.command else command;
        settings = if commandCfg ? settings then commandCfg.settings else { };
      in
      renderFrontmatter settings
    }

    ${
      let
        commandCfg = if command ? command then command.command else command;
        bodySource = if commandCfg ? bodySource then commandCfg.bodySource else "";
      in
      renderBodySource bodySource
    }
  '';

  renderAgents =
    {
      agents,
      userAgents ? { },
    }:
    let
      merged = lib.recursiveUpdate agents userAgents;
      enabled = lib.filterAttrs (_: agent: if agent ? enable then agent.enable else true) merged;
    in
    lib.mapAttrs (_: renderAgent) enabled;

  renderCommands =
    {
      agents,
      userAgents ? { },
    }:
    let
      merged = lib.recursiveUpdate agents userAgents;
      enabled = lib.filterAttrs (_: agent: if agent ? enable then agent.enable else true) merged;
      withCommand = lib.filterAttrs (_: agent: agent ? command) enabled;
    in
    lib.listToAttrs (
      map (
        name:
        let
          entry = withCommand.${name};
          commandCfg = entry.command;
          fileName = if commandCfg ? fileName then commandCfg.fileName else "${name}.md";
        in
        lib.nameValuePair fileName (renderCommand entry)
      ) (lib.attrNames withCommand)
    );
in
{
  inherit
    renderFrontmatter
    renderAgent
    renderAgents
    renderCommand
    renderCommands
    ;
}
