{
  flake.modules = {
    nixos.networking = {config, ...}: let
      cfg = config.services.tailscale;
    in {
      sops.secrets."tailscale/authKey" = {};
      networking.firewall = {
        trustedInterfaces = [cfg.interfaceName];
        allowedUDPPorts = [cfg.port];
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
