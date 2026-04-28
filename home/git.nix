{ pkgs, profile, ... }:

let
  isWork = profile == "work";
in
{
  programs.git = {
    enable = true;
    userName = "Gunnar Sundberg";
    userEmail =
      if isWork
      then "gunnar.sundberg@fastly.com"
      else "gunnarsundberg@pm.me";
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
      format = "ssh";
      key =
        if isWork
        then "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFha1Gd04htDhNUVjawcAOK2VJ+Qaq0TQTRBQufJkEX2"
        else "";
      signByDefault = true;
      signer =
       if pkgs.stdenv.isDarwin
       then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
       else "{pkgs._1password-gui}/bin/op-ssh-sign";
    };
  };

  programs.jujutsu.enable = true;
}
