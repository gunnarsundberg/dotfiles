{ pkgs, lib, profile, inputs, ... }:

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
		inputs.direnv-instant.homeModules.direnv-instant
  ];

  home.username = "gunnar";
  home.homeDirectory = lib.mkForce "/Users/gunnar";
  home.stateVersion = "26.05";

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
  ] ++ lib.optionals (!isWork) [
		inputs.forgecode.packages.${pkgs.system}.default
	] ++ lib.optionals isWork [
		inputs.forgecode-sso.packages.${pkgs.system}.default
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
			enable = true;
			enableFishIntegration = false;
			nix-direnv.enable = true;
		};
		direnv-instant = {
			enable = true;
			enableFishIntegration = true;
		};
	};
}
