# Installing Phira for OpenCode

This guide installs `phira` from a release ZIP. You do not need Nix locally.

## Prerequisites

- [OpenCode](https://opencode.ai) installed
- `unzip` installed

## Installation Steps

### 1. Download the release ZIP

Open the releases page and download the asset named `phira-opencode-<tag>.zip`:

- https://github.com/phira-ai/Phira/releases

Save it anywhere, for example:

- `$HOME/Downloads/phira-opencode-<tag>.zip`

### 2. Unpack to a local install folder

```bash
mkdir -p "$HOME/.config/opencode/phira"
unzip -o "$HOME/Downloads/phira-opencode-<tag>.zip" -d "$HOME/.config/opencode/phira"
```

After unzip, you should have:

- `$HOME/.config/opencode/phira/agents`
- `$HOME/.config/opencode/phira/skills`
- `$HOME/.config/opencode/phira/commands`
- `$HOME/.config/opencode/phira/plugins`

### 3. Symlink into OpenCode

```bash
mkdir -p "$HOME/.config/opencode/agents"
mkdir -p "$HOME/.config/opencode/skills"
mkdir -p "$HOME/.config/opencode/commands"
mkdir -p "$HOME/.config/opencode/plugins"

for f in "$HOME/.config/opencode/phira/agents/"*.md; do
  ln -sf "$f" "$HOME/.config/opencode/agents/$(basename "$f")"
done

for f in "$HOME/.config/opencode/phira/commands/"*.md; do
  ln -sf "$f" "$HOME/.config/opencode/commands/$(basename "$f")"
done

for d in "$HOME/.config/opencode/phira/skills/"*; do
  name="$(basename "$d")"
  rm -rf "$HOME/.config/opencode/skills/$name"
  ln -s "$d" "$HOME/.config/opencode/skills/$name"
done

ln -sf "$HOME/.config/opencode/phira/plugins/archivist-auto.js" "$HOME/.config/opencode/plugins/archivist-auto.js"
```

### 4. Restart OpenCode

Restart OpenCode so it reloads agents, skills, commands, and plugins.

## Verify

```bash
ls "$HOME/.config/opencode/agents" | grep '^phira'
ls "$HOME/.config/opencode/commands" | grep -E '^(a|h|i|p|r)\.md$'
ls "$HOME/.config/opencode/skills" | grep '^phira-'
ls "$HOME/.config/opencode/plugins" | grep '^archivist-auto\.js$'
```

## Ask OpenCode to install it for you

Paste this into OpenCode:

```text
Install Phira for me by following INSTALL.md in this repository exactly.

Use:
- Release page: https://github.com/phira-ai/Phira/releases
- Asset name pattern: phira-opencode-<tag>.zip
- Install path: ~/.config/opencode/phira

Then verify:
1) phira agents are linked in ~/.config/opencode/agents
2) /p /h /i /r /a command files are linked in ~/.config/opencode/commands
3) phira-* skills are linked in ~/.config/opencode/skills
4) archivist-auto.js is linked in ~/.config/opencode/plugins
```

## Updating

1. Download the newer release ZIP from https://github.com/phira-ai/Phira/releases
2. Unzip again into `~/.config/opencode/phira` with `unzip -o ...`
3. Restart OpenCode

## Build from source (optional)

If you prefer building locally, you can still use Nix:

```bash
git clone https://github.com/phira-ai/Phira "$HOME/.config/opencode/phira-src"
cd "$HOME/.config/opencode/phira-src"
nix build .#phira
```

Then use `result/agents`, `result/skills`, `result/commands`, and `result/plugins` the same way as above.
