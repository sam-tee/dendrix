{
  flake.modules.nixos = {
    gdm = _: {
      services.displayManager.gdm.enable = true;
    };
    greetd = _: {
      programs.regreet.enable = true;
    };
    ly = _: {
      services.displayManager.ly.enable = true;
    };
    plm = _: {
      services.displayManager.plasma-login-manager.enable = true;
    };
    sddm = {pkgs, ...}: {
      environment.systemPackages = [pkgs.sddm-astronaut];
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
  };
}
