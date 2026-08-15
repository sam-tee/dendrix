{
  moduleWithSystem,
  self,
  ...
}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
in {
  flake.modules = {
    generic.default = self.modules.generic.cli;
    generic.cli = moduleWithSystem ({self', ...}: {
      lib,
      pkgs,
      ...
    }: {
      environment = {
        variables = {
          BAT_THEME = "base16";
          NH_FLAKE = "$HOME/dendrix";
        };
        systemPackages = with pkgs; [
          alejandra
          atuin
          bat
          btop
          direnv
          dua
          eza
          fzf
          lazygit
          nano
          nixd
          ripgrep
          speedtest-cli
          tldr
          wget
          yazi
          zellij
          zoxide
          self'.packages.nhw
        ];
      };
      programs = {
        bat.enable = true;
        direnv = {
          enable = true;
          silent = true;
          nix-direnv.enable = true;
        };
        lazygit.enable = true;
        zoxide.enable = true;
        zsh.interactiveShellInit = lib.mkAfter ''
          function y() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
            command yazi "$@" --cwd-file="$tmp"
            if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
              builtin cd -- "$cwd"
            fi
            rm -f -- "$tmp"
          }
        '';
      };
    });
    nixos.default = self.modules.nixos.cli;
    nixos.cli = {
      lib,
      pkgs,
      ...
    }: {
      console.colors = with attrs.${defaultVariant};
        [base00 base08 base0B base0A base0D base0E base0C base05 base03 base08 base0B base0A base0D base0E base0C base07]
        |> map (i: lib.removePrefix "#" i);
      environment.systemPackages = with pkgs; [
        lm_sensors
        lshw
        pciutils
        usbutils
        wakeonlan
      ];
    };
  };
}
