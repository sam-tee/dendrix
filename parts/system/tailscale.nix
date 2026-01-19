{
  flake.modules = {
    nixos.networking = {config, ...}: {
      sops.secrets."tailscale/authKey" = {};
      networking = {
        nameservers = ["100.100.100.100" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
        search = ["scylla-goblin.ts.net"];
      };
      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."tailscale/authKey".path;
      };
    };

    darwin.networking = _: {
      services.tailscale.enable = true;
    };
  };
}
