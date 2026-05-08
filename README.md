# Gunnar's Nix Config

Personal macOS configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and
[home-manager](https://github.com/nix-community/home-manager). This repo is the base layer;
work-specific config lives in a separate `work-dotfiles` repo that imports `homeModules.base`
and `darwinModules.common` from here.

## First-time setup

```sh
# 1. Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Restart your shell, then clone this repo
jj git clone <repo-url> ~/.config/nix-config

# 3. Bootstrap nix-darwin (first run only — installs the darwin-rebuild command)
nix run nix-darwin -- switch --flake ~/.config/nix-config

# 4. All subsequent rebuilds
darwin-rebuild switch --flake ~/.config/nix-config
```

## Updating inputs

```sh
nix flake update            # update all inputs (nixpkgs, home-manager, forgecode, etc.)
darwin-rebuild switch --flake ~/.config/nix-config
```

To update a single input:

```sh
nix flake update forgecode
```

## Adding a new machine

1. Create `hosts/<hostname>.nix` with host-specific settings (system packages, hostname, etc.)
2. Add a `darwinConfigurations."<hostname>"` entry in `flake.nix`
3. Set the `profile` specialArg to `"personal"`, `"work"`, or `"server"`
4. Run `nix run nix-darwin -- switch --flake ~/.config/nix-config` on the new machine

## Profile system

All home-manager modules receive a `profile` argument. Use it for conditional config:

| Value | Machine | Notes |
|---|---|---|
| `"personal"` | Personal Intel Mac | Anthropic API key via env var |
| `"work"` | Work machine (via work-dotfiles) | Bedrock via AWS SSO |
| `"server"` | Headless Linux | AI tools excluded |

## Structure

```
flake.nix                     # Entry point — declares machines and exports reusable modules
hosts/
  darwin-common.nix           # Shared macOS settings (Homebrew, system defaults, fonts)
  macbook-pro.nix             # Personal MacBook Pro (x86_64-darwin)
home/
  default.nix                 # Home-manager entry — packages, env vars, forgecode option
  shell.nix                   # Fish, fzf, zoxide, direnv
  git.nix                     # Git + jujutsu (SSH signing via 1Password, profile-aware)
  tmux.nix                    # Tmux config
  neovim.nix                  # Neovim (symlinks nvim/ into ~/.config/nvim)
  ai-agents.nix               # Pi + Forge — declarative AI tooling (see AI Tools below)
  nvim/                       # Lua config, symlinked verbatim
  pi/
    AGENTS.md                 # Global Pi context file (when to delegate to Forge)
    extensions/
      forge-agent.ts          # Pi extension: registers the `forge` tool
  forge/
    agents/
      pi-delegate.md          # Forge agent definition for Pi-delegated tasks
    commands/
      check.md                # /check custom command (lint + test + fix)
shells/
  base-go.nix                 # Composable Go dev shell
  base-python.nix             # Composable Python dev shell
  base-rust.nix               # Composable Rust dev shell
```

> **Note:** `darwin-common.nix` and `default.nix` at the repo root are dead code from an
> earlier layout. They are not imported by `flake.nix` and can be ignored.

## AI Tools

This config declaratively manages two AI coding tools: **Pi** (orchestrator/TUI) and
**Forge** (coding agent). They are set up to work together: Pi delegates coding tasks to
Forge via a custom extension.

### What gets installed

- **Pi** (`~/.pi/`) — installed from the official GitHub release tarball (self-contained
  binary, no Node.js or Bun required). Settings at `~/.pi/agent/settings.json` are a
  read-only Nix store symlink.
- **Forge** (`~/.forge/`) — installed via the `forgecode` flake input. The `pi-delegate`
  agent and `/check` command are placed into `~/.forge/` as individual symlinks; credentials
  and conversation history remain mutable.

### Provider configuration (profile-conditioned)

| Profile | Provider | How to authenticate |
|---|---|---|
| `personal` | Anthropic direct | Set `ANTHROPIC_API_KEY` in shell env |
| `work` | AWS Bedrock | `aws sso login --profile bedrock` |

### Pi extension: the `forge` tool

`home/pi/extensions/forge-agent.ts` registers a `forge` tool that Pi's LLM can call.
When Pi decides a task needs code changes, it calls this tool, which spawns
`forge --agent <x> -p "..."` as a subprocess and streams the output back to the Pi TUI.

| Agent flag | Use case |
|---|---|
| `sage` | Read-only research — no file changes |
| `muse` | Planning and impact analysis |
| `forge` | Implementation (default) |

### Managing Pi extensions at runtime

Pi's `settings.json` and `~/.config/ai/pi/extensions/` are read-only Nix store symlinks.
Use `darwin-rebuild switch` to deploy changes, then `/reload` in a running Pi session to
pick them up without restarting.

For extensions under active development, drop `.ts` files directly into
`~/.pi/agent/extensions/` (mutable, auto-discovered by Pi) and use `/reload`. Once stable,
move them into `home/pi/extensions/` and deploy via Nix.

To add a third-party Pi package, add it to the `packages` array in `home/ai-agents.nix`
rather than running `pi install` (which would try to write to the read-only `settings.json`).

### Upgrading Pi

Bump `piVersion` in `home/ai-agents.nix` and update both `sha256` hashes:

```sh
nix-prefetch-url --type sha256 \
  https://github.com/earendil-works/pi/releases/download/vVER/pi-darwin-arm64.tar.gz
nix-prefetch-url --type sha256 \
  https://github.com/earendil-works/pi/releases/download/vVER/pi-darwin-x64.tar.gz
```

## Exported modules

`flake.nix` exports two reusable modules consumed by `work-dotfiles`:

```nix
darwinModules.common   # ./hosts/darwin-common.nix
homeModules.base       # ./home  (the entire home directory)
```

Any module added to `home/` and imported in `home/default.nix` automatically flows to
machines that consume `homeModules.base`.
