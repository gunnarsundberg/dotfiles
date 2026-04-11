# Gunnar's Nix Config

## First-time setup

```bash
# 1. Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Restart your shell, then clone this repo
git clone <this-repo> ~/.config/nix-config
cd ~/.config/nix-config

# 3. Bootstrap nix-darwin (first run only)
nix run nix-darwin -- switch --flake .

# 4. All subsequent rebuilds
darwin-rebuild switch --flake .
```

## Adding a new machine

1. Create `hosts/<hostname>.nix` with host-specific settings
2. Add a new `darwinConfigurations` or `nixosConfigurations` entry in `flake.nix`
3. Set the `profile` specialArg to `"personal"`, `"work"`, or `"server"`

## Updating

```bash
cd ~/.config/nix-config
nix flake update   # update all inputs (nixpkgs, home-manager, etc.)
darwin-rebuild switch --flake .
```

## Structure

```
├── flake.nix                 # Entry point — declares all machines
├── hosts/
│   ├── darwin-common.nix     # Shared macOS settings (homebrew, defaults)
│   └── macbook-pro.nix       # This specific Mac
└── home/
    ├── default.nix           # Home-manager entry — packages, env vars
    ├── shell.nix             # Fish, fzf, zoxide
    ├── git.nix               # Git + jujutsu (profile-aware)
    ├── tmux.nix              # Tmux config
    ├── neovim.nix            # Neovim (symlinks nvim/ directory)
    └── nvim/                 # Your existing Lua config, verbatim
```
