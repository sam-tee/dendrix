{
  flake.modules.nixos.sddm = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = [
      (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    ];
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = username;
      };
      sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = with pkgs.qt6; [
          qtsvg
          qtmultimedia
          qtvirtualkeyboard
        ];
      };
    };
  };
}
