{inputs, ...}: {
  flake.nixosConfigurations."a3" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = with inputs.self.modules.nixos; [
      user
    ];
  };
}
