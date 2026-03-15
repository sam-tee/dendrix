{
  flake.modules.nixos = {
    plasmaHM = {inputs, ...}: {
      imports = with inputs.self.modules.nixos; [
        hm
        plasma
      ];
      home-manager.sharedModules = [inputs.self.modules.homeManager.plasma];
    };
    plasmaMobileHM = {
      inputs,
      pkgs,
      ...
    }: {
      imports = [inputs.self.modules.nixos.plasmaHM];
      environment.systemPackages = [pkgs.maliit-keyboard];
      services.displayManager.sddm = {
        extraPackages = [pkgs.maliit-keyboard];
        #settings.Wayland.CompositorCommand = "${pkgs.kdePackages.kwin}/bin/kwin_wayland --no-global-shortcuts --no-kactivities --no-lockscreen --locale1 --inputmethod maliit-keyboard";
      };
    };
  };
}
