# Gunnar's dotfiles

This repository is a [chezmoi](https://www.chezmoi.io/) source directory. It manages user-level configuration shared between macOS and Linux, with machine role (`personal` or `work`) separate from OS. Chezmoi detects the OS; role, Git identity, and hardware capabilities are local machine data, not repository-wide settings.

## Bootstrap

Install chezmoi using the operating system's package manager, then initialize and apply this source:

```sh
chezmoi init <repo-url>
chezmoi apply
```

On first use, `.chezmoi.toml.tmpl` prompts for role, Git email, SSH signing key, and whether the machine has Apple T2 hardware. Leave the signing-key value blank if SSH signing is not configured; Git signing is then disabled. Prompts populate local chezmoi data. To review or change those values later, edit `~/.config/chezmoi/chezmoi.toml`, then run `chezmoi apply`.

The package hook runs after chezmoi deploys its files and fingerprints the active role's package data, so package-list changes rerun installation. On macOS it runs `brew bundle`; on Linux it requires `pacman` and installs the generated package list with `sudo`. The Linux package list targets Arch-based systems. Install or bootstrap chezmoi itself before the first apply.

Node.js is installed through `fnm` on both platforms, and `fnm` selects the current LTS version. npm is used only from that fnm-managed Node installation; no system npm package is installed. The user-tool hook installs agent-browser through fnm-managed npm, Oh My Pi (`omp`), and Crit on Linux; macOS installs OMP and Crit from Homebrew. OMP configuration is deployed from `dot_omp`, including native Herdr/Crit skills and role-aware MCP servers. The Fastly internal marketplace and Google Workspace MCP are work-only. Pi configuration remains deployed from `dot_pi`, but the Pi executable is not installed.

On Linux personal machines, the user-tool hook installs Proton Pass CLI into `~/.local/bin`. After applying, authenticate once and enable its user service:

```sh
pass-cli login
systemctl --user enable --now proton-pass-ssh-agent.service
```

Fish exports `SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"`; the systemd service creates that socket. On macOS, the existing LaunchAgent starts process-compose with the same socket path.

## Updating

```sh
chezmoi update   # pull source changes and apply them
chezmoi diff     # review pending changes
chezmoi apply
```

Edit tracked configuration in the source directory (`chezmoi cd`). Use `chezmoi edit <target>` to edit the source for a managed target, and `chezmoi apply` to deploy it.

## Structure

```text
.chezmoi.toml.tmpl              # local role, Git identity, hardware prompts
.chezmoiignore.tmpl             # OS/role-specific deployment exclusions
.chezmoidata/packages.yaml      # shared, OS-specific, and role-specific packages
.chezmoiscripts/                # package and user-tool lifecycle hooks
dot_config/
  git/config.tmpl               # shared Git settings, role/OS overlays
  private_fish/                 # deploys to ~/.config/fish
  private_jj/                   # deploys to ~/.config/jj
  homebrew/Brewfile.tmpl         # Darwin package manifest
  pacman/packages.txt.tmpl      # Linux package manifest
  niri/                          # Linux desktop; T2-only settings are gated
  noctalia/                      # Linux desktop; T2 backlight setting is gated
  systemd/user/                  # personal Linux Proton Pass agent service
  mcp/                           # role-aware MCP configuration
  nvim/                          # Neovim configuration
  process-compose/               # Darwin process configuration
  ghostty/                       # shared Ghostty configuration
dot_omp/agent/                 # OMP configuration, MCP servers, and native skills
dot_pi/                          # Pi settings and agent instructions
private_Library/LaunchAgents/    # macOS-only LaunchAgents
```

The Niri and Noctalia files were imported from the current Linux desktop. `.chezmoiignore.tmpl` excludes them from Darwin, excludes Homebrew files and LaunchAgents outside Darwin, and excludes the pacman manifest outside Linux. T2-specific keybindings, `tiny-dfr` startup, and Noctalia backlight configuration are conditional on local `features.t2` data. The Linux agent service is only deployed for personal-role machines; macOS keeps its LaunchAgent and process-compose configuration.

## Package lists

`.chezmoidata/packages.yaml` separates packages with the same package-manager name on both systems (`common`) from manager-specific lists (`darwin.formula`, `darwin.cask`, and `linux.pacman`). Role-specific packages live under each OS's `roles` mapping. Keep a package in `common` only when the same package name and install intent apply to both systems; put naming or manager differences in the corresponding OS list.

Darwin packages are rendered into `~/.config/homebrew/Brewfile`. Linux packages are rendered into `~/.config/pacman/packages.txt`. The Linux hook uses pacman directly; it does not install or configure system services, drivers, kernels, or `/etc` files.
