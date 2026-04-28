{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName  = "Gunnar Sundberg";
    userEmail = "gunnarsundberg@pm.me";
    extraConfig = {
      init.defaultBranch = "main";
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      pull.rebase = true;
    };
    ignores = [ ];
    settings = {
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
    signing = {
      format      = "ssh";
      key         = "";
      signByDefault = true;
      signer =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "{pkgs._1password-gui}/bin/op-ssh-sign";
    };
  };

  programs.jujutsu.enable = true;
}
