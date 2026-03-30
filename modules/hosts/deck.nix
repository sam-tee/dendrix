{self, ...}: let
  hostname = "deck";
in {
  flake = {
    hosts.${hostname} = {
      username = "deck";
      system = "x86_64-linux";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTZGNcChKAHaj3NdIHlaXHNLqsonXKkUqQRtYGyZM6f";
      syncID = "";
    };

    homeConfigurations = self.lib.mkHome hostname;

    modules.homeManager.deckConfig = _: {
      imports = with self.modules.homeManager; [
        _minimal
        cliLinux
        linuxMinPkgs
        plasma
        standalone
        syncthing
        xournal
      ];
      targets.genericLinux.enable = true;
    };
  };
}
