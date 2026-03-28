{
  flake.modules.nixos.sddm = {pkgs, ...}: {
    environment.systemPackages = [
      (pkgs.sddm-astronaut.override {embeddedTheme = "black_hole";})
    ];
    services.displayManager.sddm = {
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
}
