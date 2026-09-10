{self, ...}: let
  hostname = "mba";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "aarch64-darwin";
      hostType = "darwin";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFQjvsEOeipx+aSfrT6WIEdrlMxfglSgOu2NKmpzTUA";
      syncID = "JDIBFDZ-ACBGUKG-5BRO24H-F5ESCIN-Y7YUMBL-WFQKWMZ-3ZORMIV-YFCN4AQ";
      tailscaleIP = "100.100.10.12";
    };

    darwinConfigurations = self.lib.mkDarwin hostname;

    modules.darwin.${hostname} = _: {
      imports = with self.modules.darwin; [
        paneru
      ];
    };
  };
}
