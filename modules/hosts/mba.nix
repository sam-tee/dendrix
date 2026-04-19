{self, ...}: let
  hostname = "mba";
in {
  flake.config = {
    hosts.${hostname} = {
      username = "sam";
      system = "aarch64-darwin";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFQjvsEOeipx+aSfrT6WIEdrlMxfglSgOu2NKmpzTUA";
      syncID = "OBTLFOZ-UTYW6JE-3MDA6YU-YXOZPEI-62JF23C-EAII64O-TSBIVZG-TBARUQX";
    };
    darwinConfigurations = self.lib.mkDarwin hostname;

    modules.darwin.mbaConfig = _: {
      imports = with self.modules.darwin; [
        _default
        hm
      ];
      home-manager.sharedModules = with self.modules.homeManager; [
        _darwinMinimal
        aerospace
        extraPkgs
        syncthing
        #vscode
      ];
    };
  };
}
