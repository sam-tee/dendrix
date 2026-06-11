{self, ...}: let
  hostname = "deck";
in {
  flake = {
    hosts.${hostname} = {
      username = "deck";
      system = "x86_64-linux";
      hostType = "home";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTZGNcChKAHaj3NdIHlaXHNLqsonXKkUqQRtYGyZM6f";
      syncID = "5EJ6MDF-JXLSJ65-OFO7E6A-YAC32Z4-P2HHOFV-W4WXT7H-B5KAUQY-4NLT4AF";
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
      home.file.".ssh/authorized_keys".text = self.hosts.${hostname}.pubKey;
    };
  };
}
