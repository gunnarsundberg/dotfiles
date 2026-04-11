{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    prefix = "C-Space";
    baseIndex = 1;
    mouse = true;
    terminal = "xterm-256color";
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      set -g pane-base-index 1
      set-option -g renumber-windows on
      set-option -sa terminal-overrides ",xterm*:Tc"
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
