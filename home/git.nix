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
      then "gunnar@work.com"
      else "gunnar@personal.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.jujutsu.enable = true;
}
