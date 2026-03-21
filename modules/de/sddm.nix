{
  flake.modules.nixos.sddm = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      (
        catppuccin-sddm.override {
          flavor = "mocha";
          accent = "mauve";
        }
      )
      sddm-astronaut
      sddm-chili-theme
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
