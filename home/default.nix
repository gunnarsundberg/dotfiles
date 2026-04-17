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
  home.homeDirectory = lib.mkForce "/Users/gunnar";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    fzf
    zoxide
    fd
    bat
    ripgrep
    htop
    jujutsu
    gh
    tree-sitter
    lua-language-server
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  xdg.configFile."ghostty/config" = lib.mkIf (!isServer) {
    text = ''
      keybind = shift+enter=text:\n
    '';
  };

  programs.home-manager.enable = true;
}
