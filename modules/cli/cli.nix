let
  programs = {
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    lazygit.enable = true;
    zoxide.enable = true;
  };
  packages = pkgs:
    with pkgs; [
      atuin
      bat
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
      inherit programs;
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
      programs =
        {
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
