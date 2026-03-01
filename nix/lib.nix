{ lib }:
let
  toYamlScalar = value: builtins.toJSON value;

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
        settings0 = if agent ? settings then agent.settings else { };
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

    ${builtins.readFile agent.bodySource}
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
in
{
  inherit
    renderFrontmatter
    renderAgent
    renderAgents
    ;
}
