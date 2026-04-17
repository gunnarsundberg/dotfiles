{ profile, ... }:

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
      push.autoSetupRemote = true;
    };
  };

  programs.jujutsu.enable = true;
}
