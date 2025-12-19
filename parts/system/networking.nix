{
  flake.modules.darwin.networking = {...}: {
    services.tailscale.enable = true;
  };

  flake.modules.nixos.networking = {...}: {
    networking = {
      nameservers = ["100.100.100.100" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
      search = ["scylla-goblin.ts.net"];
      networkmanager.enable = true;
      useNetworkd = true;
    };
    services.tailscale.enable = true;
  };
}
