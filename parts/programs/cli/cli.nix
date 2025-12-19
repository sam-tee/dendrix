let
  programs = {
    bat.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    lazygit.enable = true;
    tmux.enable = true;
    zoxide.enable = true;
  };
  packages = pkgs:
    with pkgs; [
      alejandra
      dust
      fastfetch
      nano
      nix-search-cli
      nixd
      python3
      ruff
      speedtest-cli
      tldr
      ty
    ];
in {
  flake.modules = {
    nixos.cli = {pkgs, ...}: {
      inherit programs;
      environment.systemPackages = with pkgs;
        [
          eza
          fzf
          inxi
          lm_sensors
          lshw
          pciutils
          ripgrep
          usbutils
          v4l-utils
        ]
        ++ (packages pkgs);
    };

    homeManager.cli = {pkgs, ...}: {
      programs = programs // {ripgrep.enable = true;};
      home.packages = packages pkgs;
    };

    homeManager.cliLinux = {pkgs, ...}: {
      home.packages = with pkgs; [
        inxi
        lm_sensors
        lshw
        pciutils
        usbutils
        v4l-utils
      ];
    };

    darwin.cli = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        eza
        fzf
        inxi
        lm_sensors
        lshw
        pciutils
        ripgrep
        usbutils
        v4l-utils
      ]
      ++ (packages pkgs);
    };
  };
}
