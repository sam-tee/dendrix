{self, ...}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
  c = attrs.${defaultVariant};
in {
  flake.modules.generic = {
    default = self.modules.generic.tmux;
    tmux = _: {
      programs.tmux = {
        enable = true;
        extraConfig = ''
          set -g allow-passthrough on
          set -as terminal-features ',*:RGB'
          set -g default-terminal "tmux-256color"
          set -as terminal-overrides ",xterm-256color:Tc,ghostty:Tc"
          set -g mouse on

          set -g history-limit 50000
          set -s escape-time 0
          set -g focus-events on
          setw -g aggressive-resize on
          set -g clock-mode-style 24
          set -g renumber-windows on
          set -g base-index 1
          setw -g pane-base-index 1
          set -g detach-on-destroy off
          set -g set-clipboard on
          set -g extended-keys on
          set -g status-interval 5

          set -g status on
          set -g status-position bottom
          set -g status-justify left
          set -g status-style "bg=${c.base01},fg=${c.base05}"
          set -g window-status-current-style "bg=${c.base02},fg=${c.base05},bold"
          set -g window-status-style "bg=${c.base01},fg=${c.base05}"
          set -g mode-style "bg=${c.base02},fg=${c.base05}"
          set -g pane-border-style "fg=${c.base03}"
          set -g pane-active-border-style "fg=${c.base0D}"
          set -g message-style "bg=${c.base02},fg=${c.base05}"
          set -g message-command-style "bg=${c.base02},fg=${c.base05}"
        '';
      };
    };
  };
}
