{
  config,
  ...
}: {
    flake.modules.darwin.networking = {
      networking = {
        hostName = config.hostname;
        computerName = config.hostname;
        dns = ["100.100.100.100" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
        search = ["scylla-goblin.ts.net"];
      };
      services.tailscale.enable = true;
    };

    flake.modules.nixos.networking = {
      networking = {
        hostName = config.hostname;
        nameservers = ["100.100.100.100" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
        networkmanager.enable = true;
        search = ["scylla-goblin.ts.net"];
        useNetworkd = true;
      };
      services.tailscale.enable = true;
    };
}
