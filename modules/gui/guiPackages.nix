{self, ...}: {
  flake.modules = {
    nixos = {
      gui = self.modules.nixos.linuxBase;
      linuxBase = {
        pkgs,
        lib,
        ...
      }: {
        imports = with self.modules.generic; [ghostty xournal zed];
        xdg.mime.enable = true;
        environment.systemPackages = with pkgs;
          [
            bitwarden-desktop
            proton-vpn
          ]
          ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") (with pkgs; [
            discord
            spotify
          ]);
        programs.localsend.enable = true;
      };
      linuxAll = {pkgs, ...}: {
        imports = [self.modules.nixos.gui];
        environment.systemPackages = with pkgs; [
          anki
          baobab
          chromium
          google-chrome
          gnome-disk-utility
          haruna
          libreoffice
          nautilus
        ];
      };
    };
    darwin = {
      default = self.modules.darwin.macosBase;
      macosBase = {pkgs, ...}: {
        imports = with self.modules.generic; [ghostty zed];
        environment.systemPackages = with pkgs; [
          discord
          iina
          skimpdf
          spotify
        ];
        homebrew = {
          casks = [
            "google-chrome"
            "localsend"
            "raycast"
          ];
          masApps."Bitwarden" = 1352778147;
        };
      };
    };
  };
}
