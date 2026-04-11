{ pkgs, lib, profile, ... }:

let
  isWork = profile == "work";
  isServer = profile == "server";
in
{
  imports = [
    ./shell.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
  ];

  home.username = "gunnar";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/gunnar"
    else "/home/gunnar";

  home.stateVersion = "24.11";

  # ── Packages (replaces your flox manifest.toml) ──────────────────────
  home.packages = with pkgs; [
    # shell tools
    fzf
    zoxide
    fd
    bat
    ripgrep
    htop
    jujutsu
    gh
    lazyjj
    nushell

    # neovim ecosystem
    tree-sitter
    lua-language-server
    vscode-langservers-extracted  # json-ls, html-ls, css-ls, eslint-ls
  ] ++ lib.optionals (!isServer) [
    # GUI / interactive-only packages
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Ghostty config (installed via homebrew cask, config via home-manager)
  xdg.configFile."ghostty/config" = lib.mkIf (!isServer) {
    text = ''
      keybind = shift+enter=text:\n
    '';
  };

  programs.home-manager.enable = true;
}
