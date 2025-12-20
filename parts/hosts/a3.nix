{inputs, ...}: let
  hostname = "a3";
  inherit (import ./_helpers.nix inputs) mkNixos;
in {
  flake.nixosConfigurations."${hostname}" = mkNixos {
    inherit hostname;
    username = "sam";
    system = "x86_64-linux";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+vBOkmJ3txsCh0rWlmYug/IFQIg8rdqQ420QYOinJV a3";
    nixosModules = with inputs.self.modules.nixos; [
      steam
      plasma
    ];
    homeModules = with inputs.self.modules.homeManager; [
      linuxExtraPkgs
      plasma
      vscode
    ];
  };
}
