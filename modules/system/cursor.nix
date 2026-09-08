{self, ...}: {
  flake.modules = let
    inherit (self.cosmetic.cursor) name pkgsName size;
  in {
    nixos.default = self.modules.nixos.cursor;
    nixos.cursor = {
      pkgs,
      lib,
      ...
    }: {
      hjem.extraModules = [self.modules.hjem.cursor];
      environment = {
        systemPackages = [(pkgsName pkgs)];
        sessionVariables = {
          XCURSOR_THEME = name;
          XCURSOR_SIZE = toString size;
          HYPRCURSOR_THEME = name;
          HYPRCURSOR_SIZE = toString size;
        };
      };
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            cursor-theme = name;
            cursor-size = lib.gvariant.mkInt32 size;
          };
        }
      ];
    };
    hjem.cursor = _: {
      xdg = {
        config.files = {
          "gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-cursor-theme-name=${name}
            gtk-cursor-theme-size=${toString size}
          '';
          "gtk-4.0/settings.ini".text = ''
            [Settings]
            gtk-cursor-theme-name=${name}
            gtk-cursor-theme-size=${toString size}
          '';
        };
        data.files."icons/default/index.theme".text = ''
          [Icon Theme]
          Inherits=${name}
        '';
      };
    };
  };
}
