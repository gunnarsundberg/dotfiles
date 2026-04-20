{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
			nvim-lspconfig
			oil-nvim
			mini-pick
			mini-completion
			nvim-treesitter
			nvim-treesitter-textobjects
			nvim-treesitter-context
			vim-tmux-navigator
			rustaceanvim
			gruvbox-material
			(pkgs.vimUtils.buildVimPlugin {
			  pname = "jjsigns.nvim";
				version = "2025-08-27";
				src = pkgs.fetchFromGitHub {
					owner = "evanphx";
					repo = "jjsigns.nvim";
					rev = "f5f5cefef0945cc00ba914584275f9cef8c2e792";
					sha256 = "sha256-nZu61pIkd85nISneMBy82ZZPB7Wj85Uy2LsOoWo99CE=";
				};
			})
		];
  };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
