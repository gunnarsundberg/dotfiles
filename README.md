# Gunnar's dotfiles

This repository is a [chezmoi](https://www.chezmoi.io/) source directory. It manages user-level configuration shared between macOS and Linux, with machine role (`personal` or `work`) separate from OS. Chezmoi detects the OS; role, Git identity, and hardware capabilities are local machine data, not repository-wide settings.

## Bootstrap

Install chezmoi using the operating system's package manager, then initialize and apply this source:

```sh
chezmoi init <repo-url>
chezmoi apply
```

On first use, `.chezmoi.toml.tmpl` prompts for role, Git email, SSH signing key, and whether the machine has Apple T2 hardware. Leave the signing-key value blank if SSH signing is not configured; Git signing is then disabled. Prompts populate local chezmoi data. To review or change those values later, edit `~/.config/chezmoi/chezmoi.toml`, then run `chezmoi apply`.

The package hook runs after chezmoi deploys its files and fingerprints the active role's package data, so package-list changes rerun installation. On macOS it runs `brew bundle`; on Linux it requires pacman and installs Arch repository packages with `sudo`. Install or bootstrap chezmoi itself before the first apply.

Node.js is installed through `fnm` on both platforms, and `fnm` selects the current LTS version. npm is used only from that fnm-managed Node installation; no system npm package is installed. The user-tool hook installs agent-browser on work profiles only, Oh My Pi (`omp`), GrepAI, Herdr, and Crit on Linux; macOS installs OMP, GrepAI, Herdr, and Crit from Homebrew. OMP configuration is deployed from `dot_omp`, including design-discovery, debugging, TDD, verification, Herdr, and Crit skills plus role-aware MCP servers. Chrome DevTools, the Fastly internal marketplace, Google Workspace MCP, and Atlassian MCP are work-only.

On Linux personal machines, the user-tool hook installs Proton Pass CLI into `~/.local/bin`. After applying, authenticate once and enable its user service:

```sh
pass-cli login
systemctl --user enable --now proton-pass-ssh-agent.service
```

Fish exports `SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"`; the systemd service creates that socket. On macOS, the existing LaunchAgent starts process-compose with the same socket path.

Tailscale is included in the personal package profile on both platforms. On CachyOS, after applying, enable and start the system daemon once:

```sh
sudo systemctl enable --now tailscaled
```

Sign in to your tailnet once with Tailscale. The system service starts at boot and runs without a user session.

On macOS, launch Tailscale after installation, complete its onboarding, approve the VPN/system extension if prompted, and sign in. Enable Tailscale in **System Settings → General → Login Items** so it starts when you log in. The macOS app runs in the logged-in user session; it does not provide a system daemon for pre-login access.

Verify connectivity with `tailscale status`. On CachyOS, `systemctl is-enabled tailscaled` and `systemctl is-active tailscaled` verify boot enablement and current service state.

## T2 Linux setup

When `features.t2` is enabled on Linux, the pacman manifest installs `tiny-dfr` and `t2fanrd`; use a pacman repository that provides these T2 packages (CachyOS does). The `tiny-dfr` package starts its system service from udev when the Touch Bar devices appear, so no Niri startup entry or manual service enablement is needed.

After applying on a T2 Linux machine, enable the fan controller once:

```sh
sudo systemctl enable --now t2fanrd.service
```

`t2fanrd` reads its optional fan curve from `/etc/t2fand.conf`. Chezmoi does not manage this root-owned system configuration. This CachyOS installation also has local suspend/resume units for `t2fanrd` and `tiny-dfr`; their behavior is not managed by chezmoi and should be validated on each kernel/device before copying them elsewhere.

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
  pacman/packages.txt.tmpl      # Arch repository package manifest
  niri/                          # Linux desktop; T2-only settings are gated
  noctalia/                      # Linux desktop; T2 backlight setting is gated
  systemd/user/                  # personal Linux Proton Pass agent service
  nvim/                          # Neovim configuration
  process-compose/               # Darwin process configuration
  ghostty/                       # shared Ghostty configuration
dot_omp/agent/                 # OMP configuration, MCP servers, and native skills
private_Library/LaunchAgents/    # macOS-only LaunchAgents
```

The Niri and Noctalia files were imported from the current Linux desktop. `.chezmoiignore.tmpl` excludes them from Darwin, excludes Homebrew files and LaunchAgents outside Darwin, and excludes the pacman manifest outside Linux. T2-specific keybindings and Noctalia backlight configuration are conditional on local `features.t2` data. T2 Linux packages are also hardware-gated; `tiny-dfr` starts through package-provided udev/systemd rules, while `t2fanrd` requires one-time service enablement. The Linux agent service is only deployed for personal-role machines; macOS keeps its LaunchAgent and process-compose configuration. Tailscale is installed only for personal-role machines, with CachyOS's system service enabled manually as documented above and macOS startup managed through Login Items.

## Package lists

`.chezmoidata/packages.yaml` separates packages with the same package-manager name on both systems (`common`) from manager-specific lists (`darwin.formula`, `darwin.cask`, and `linux.pacman`). Role-specific packages live under each OS's `roles` mapping; Linux roles may also include AUR packages installed by Shelly. `linux.t2.pacman` holds T2-hardware packages controlled by `features.t2`. Keep a package in `common` only when the same package name and install intent apply to both systems; put naming or manager differences in the corresponding OS list.

Darwin packages are rendered into `~/.config/homebrew/Brewfile`; Linux Arch repository packages are rendered into `~/.config/pacman/packages.txt`. The Linux hook does not install or configure system services, drivers, kernels, or `/etc` files. System services and hardware configuration remain explicit privileged setup steps. GrepAI is installed from its official release installer into `~/.local/bin` on Linux.

The personal Linux profile installs `jellyfin-tui` from the AUR using Shelly. This requires an AUR-enabled pacman host; Shelly interactively presents PKGBUILD review warnings before installation.
