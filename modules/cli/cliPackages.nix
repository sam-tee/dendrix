{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
  inherit (lib) removePrefix singleton;
in {
  flake.modules = {
    generic.default = self.modules.generic.cli;
    generic.cli = moduleWithSystem ({self', ...}: {pkgs, ...}: let
      terminfo =
        if pkgs.stdenv.hostPlatform.isDarwin
        then pkgs.ghostty-bin.terminfo
        else pkgs.ghostty.terminfo;
    in {
      environment = {
        variables = {
          BAT_THEME = "base16";
          NH_FLAKE = "$HOME/dendrix";
        };
        systemPackages = with pkgs; [
          alejandra
          bat
          btop
          chafa
          direnv
          dua
          eza
          fzf
          lazygit
          nixd
          ripgrep
          speedtest-cli
          terminfo
          tldr
          wget
          yazi
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
        zoxide = {
          enable = true;
          flags = ["--cmd cd"];
        };
      };
      hjem.extraModules = singleton {
        xdg.config.files = {
          "btop/btop.conf".text = ''
            color_theme = "TTY"
            vim_keys = true
          '';
          "lazygit/config.yml".text = ''
            git:
              diffRenderers:
              - colorArg: always
                command: delta --dark --paging=never --line-numbers --hyperlinks
                  --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"
                type: stdinFilter
          '';
          "yazi/yazi.toml".text = ''
            [mgr]
            linemode = "size"
            show_hidden = true
          '';
        };
      };
    });
    nixos.default = self.modules.nixos.cli;
    nixos.cli = {pkgs, ...}: {
      console.colors = with attrs.${defaultVariant};
        [base00 base08 base0B base0A base0D base0E base0C base05 base03 base08 base0B base0A base0D base0E base0C base07]
        |> map (i: removePrefix "#" i);
      environment.systemPackages = with pkgs; [
        lm_sensors
        lshw
        pciutils
        usbutils
        wakeonlan
      ];
      programs.nano.enable = false;
    };
  };
}
