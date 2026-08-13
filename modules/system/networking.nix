{self, ...}: {
  flake.modules.nixos = {
    default = self.modules.nixos.networking;
    networking = _: {
      systemd.network.wait-online.enable = false;
      networking = {
        firewall.enable = true;
        nftables.enable = true;
        networkmanager.enable = true;
      };
    };
  };
}
