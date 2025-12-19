{inputs, ...}: let
  inherit (import ./_helpers.nix inputs) mkDarwin;
in {
  flake.darwinConfigurations."mba" = mkDarwin {
    hostname = "mba";
    username = "sam";
    sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFQjvsEOeipx+aSfrT6WIEdrlMxfglSgOu2NKmpzTUA";
    homeModules = with inputs.self.modules.homeManager; [
      vscode
      extraPkgs
    ];
  };
}
