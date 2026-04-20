{ pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fish_vi_key_bindings
    '';
		
		plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
			{ name = "tide"; src = pkgs.fishPlugins.tide.src; }
			{ name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
			{ name = "bass"; src = pkgs.fishPlugins.bass.src; }
			{ 
				name = "forge-fish";
				src = pkgs.fetchFromGitHub {
          owner = "iosif2";
					repo = "forge.fish";
					rev = "ce6334c2026c75ec8beca08a2624b410d9261481";
					sha256 = "sha256-dOo5tmI6aK4RaS2iwnG85M1P9Qfx9GWAB5Mtwv4KyCc=";
				};
			}
		];
  };

  programs.fzf = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
