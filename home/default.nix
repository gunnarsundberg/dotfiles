{ config, pkgs, lib, profile, inputs, ... }:

let
  isServer = profile == "server";
in
{
  imports = [
    ./shell.nix
    ./git.nix
    ./tmux.nix
    ./neovim.nix
    inputs.direnv-instant.homeModules.direnv-instant
  ];

  options = {
    forgecode.package = lib.mkOption {
      type        = lib.types.package;
      default     = inputs.forgecode.packages.${pkgs.system}.default;
      description = "The forge binary to install. Override in work-dotfiles with forgecode-sso.";
    };
  };

  config = {

    home.username      = "gunnar";
    home.homeDirectory = lib.mkForce "/Users/gunnar";
    home.stateVersion  = "26.05";

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
      config.forgecode.package
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

    programs = {
      home-manager.enable = true;
      direnv = {
        enable               = true;
        enableFishIntegration = false;
        nix-direnv.enable    = true;
      };
      direnv-instant = {
        enable                = true;
        enableFishIntegration = true;
      };
    };
  };
}
