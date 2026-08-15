{self, ...}: {
  flake.modules = {
    nixos = {
      gui = self.modules.nixos.linuxBase;
      linuxBase = {pkgs, ...}: {
        environment.systemPackages = with pkgs;
          [
            bitwarden-desktop
            ghostty
            proton-vpn
            xournalpp
            zed-editor
          ]
          ++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") (with pkgs; [
            discord
            spotify
          ]);
        programs.localsend.enable = true;
      };
      linuxAll = {pkgs, ...}: {
        imports = [self.modules.nixos.linuxBase];
        environment.systemPackages = with pkgs; [
          anki
          baobab
          google-chrome
          gnome-disk-utility
          haruna
          libreoffice
        ];
        programs.vscode.enable = true;
      };
    };
    darwin = {
      default = self.modules.darwin.macosBase;
      macosBase = {pkgs, ...}: {
        hjem.extraModules = with self.modules.hjem; [ghostty zed];
        environment.systemPackages = with pkgs; [
          discord
          ghostty-bin
          iina
          skimpdf
          spotify
          zed-editor
        ];
        homebrew = {
          casks = [
            "google-chrome"
            "localsend"
            "raycast"
            "whatsapp"
          ];
          masApps = {"Bitwarden" = 1352778147;};
        };
      };
    };
  };
}
