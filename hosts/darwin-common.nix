{ pkgs, ... }:

{
  system.primaryUser = "gunnar";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.shells = [ pkgs.fish ];
  environment.systemPackages = with pkgs; [
    git
  ];

  users.users.gunnar.shell = pkgs.fish;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
    };
    casks = [
      "ghostty"
    ];
  };

  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
    };
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  programs.fish.enable = true;
  system.stateVersion = 6;
}
