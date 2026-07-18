{
  moduleWithSystem,
  self,
  ...
}: let
  inherit (self.cosmetic.theme) attrs defaultVariant;
  inherit (attrs.${defaultVariant}) base00 base03 base05 base07 base08 base0A base0B base0C base0D base0E;
  programs = {
    bat.enable = true;
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
    lazygit.enable = true;
    zoxide.enable = true;
  };
  packages = pkgs: self':
    with pkgs; [
      alejandra
      atuin
      bat
      btop
      direnv
      eza
      fzf
      lazygit
      nano
      ncdu
      nixd
      ripgrep
      speedtest-cli
      tldr
      wget
      yazi
      zellij
      self'.packages.nhw
    ];
in {
  flake.modules = {
    nixos.cli = moduleWithSystem ({self', ...}: {
      lib,
      pkgs,
      ...
    }: {
      imports = with self.modules.generic; [cli];
      inherit programs;
      environment.variables.BAT_THEME = "base16";
      console.colors =
        [base00 base08 base0B base0A base0D base0E base0C base05 base03 base08 base0B base0A base0D base0E base0C base07]
        |> map (i: lib.removePrefix "#" i);
      environment.systemPackages = with pkgs;
        [
          lm_sensors
          lshw
          pciutils
          usbutils
          wakeonlan
        ]
        ++ (packages pkgs self');
    });

    homeManager.cli = moduleWithSystem ({self', ...}: {pkgs, ...}: {
      imports = [self.modules.generic.cli];
      home.sessionVariables.BAT_THEME = "base16";
      nixpkgs = {
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = false;
          allowAliases = false;
          permittedInsecurePackages = ["electron-39.8.10"];
        };
        overlays = [];
      };
      programs =
        {
          fzf = {
            enable = true;
            defaultOptions = ["--preview 'bat --style=numbers --color=always {}'"];
            historyWidget.command = "";
          };
          nh = {
            enable = true;
            flake = "$HOME/dendrix";
            clean.enable = true;
          };
          ripgrep.enable = true;
          yazi = {
            enable = true;
            shellWrapperName = "y";
          };
          zellij.enable = true;
        }
        // programs;
      home.packages = packages pkgs self';
    });

    homeManager.cliLinux = {pkgs, ...}: {
      home.packages = with pkgs; [
        lm_sensors
        lshw
        pciutils
        usbutils
      ];
    };

    darwin.cli = moduleWithSystem ({self', ...}: {pkgs, ...}: {
      environment.systemPackages = packages pkgs self';
    });
  };
}
