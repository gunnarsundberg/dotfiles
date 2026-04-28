{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name  = "Gunnar Sundberg";
      user.email = "gunnarsundberg@pm.me";
      init.defaultBranch = "main";
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      pull.rebase = true;
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
    ignores = [ ];
    signing = {
      format        = "ssh";
      key           = "";
      signByDefault = true;
      signer =
        if pkgs.stdenv.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "{pkgs._1password-gui}/bin/op-ssh-sign";
    };
  };

  programs.jujutsu.enable = true;
}
