{self, ...}: let
  inherit (self.cosmetic.theme.noHash) base01 base03 base05 base07 base08 base0A base0B base0C base0D base0E;
  programs = {
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    lazygit.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
  };
  packages = pkgs:
    with pkgs; [
      atuin
      bat
      btop
      direnv
      dust
      eza
      fastfetch
      fzf
      lazygit
      nano
      ripgrep
      speedtest-cli
      tldr
      wget
      zellij
    ];
in {
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      imports = [self.modules.generic.cli];
      inherit programs;
      console.colors = [base01 base08 base0B base0A base0D base0E base0C base05 base03 base08 base0B base0A base0D base0E base0C base07];
      environment.systemPackages = with pkgs;
        [
          lm_sensors
          lshw
          pciutils
          usbutils
          wakeonlan
        ]
        ++ (packages pkgs);
    };

    homeManager.cli = {pkgs, ...}: {
      imports = [self.modules.generic.cli];
      programs =
        {
          fzf = {
            enable = true;
            defaultOptions = ["--preview 'bat --style=numbers --color=always {}'"];
          };
          ripgrep.enable = true;
          zellij.enable = true;
        }
        // programs;
      home.packages = packages pkgs;
    };

    homeManager.cliLinux = {pkgs, ...}: {
      home.packages = with pkgs; [
        lm_sensors
        lshw
        pciutils
        usbutils
      ];
    };

    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = packages pkgs;
    };
  };
}
