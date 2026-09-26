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
        extraPackages = with pkgs; [
          qt6.qtsvg
          qt6.qtmultimedia
          kdePackages.plasma-keyboard
        ];
        settings = {
          General.InputMethod = "plasma-keyboard";
          Wayland.CompositorCommand = "kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1 --inputmethod plasma-keyboard";
        };
      };
    };
  };
}
