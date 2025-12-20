{inputs, ...}: let
  hostname = "s340";
  inherit (import ./_helpers.nix inputs) mkNixos;
in {
  flake.nixosConfigurations."${hostname}" = mkNixos {
    inherit hostname;
    username = "sam";
    system = "x86_64-linux";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVmDsq/cQ+Tc5Pd5HR7vvZ22gLsMh4afo5eN/08H75O s340";
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
