{inputs, ...}: {
  flake.darwinConfigurations."mba" = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = with inputs.self.modules.darwin; [
      aerospace
      brew
      networking
      nix
      ssh
      system
      user
      hm
      {
        home-manager.sharedModules = with inputs.self.modules.home; [
          btop
        ];
      }
    ];
  };
}
