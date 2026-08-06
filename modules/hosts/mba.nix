{self, ...}: let
  hostname = "mba";
in {
  flake.config = {
    hosts.${hostname} = {
      username = "sam";
      system = "aarch64-darwin";
      hostType = "darwin";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFQjvsEOeipx+aSfrT6WIEdrlMxfglSgOu2NKmpzTUA";
      syncID = "JDIBFDZ-ACBGUKG-5BRO24H-F5ESCIN-Y7YUMBL-WFQKWMZ-3ZORMIV-YFCN4AQ";
    };
    darwinConfigurations = self.lib.mkDarwin hostname;

    modules.darwin.mbaConfig = _: {
      imports = with self.modules.darwin; [
        _default
        hm
        aerospace
      ];
      home-manager.sharedModules = with self.modules.homeManager; [
        _darwinMinimal
        extraPkgs
        syncthing
        #vscode
      ];
    };
  };
}
