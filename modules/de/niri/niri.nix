{inputs, ...}: {
  flake.modules = {
    nixos.niri = _: {
      imports = with inputs.self.modules.nixos; [
        sddm
        wm
      ];
      home-manager.sharedModules = with inputs.self.modules.homeManager; [
        niri
      ];
      programs.niri = {
        enable = true;
        useNautilus = false;
      };
    };
    homeManager.niri = _: {};
  };
}
