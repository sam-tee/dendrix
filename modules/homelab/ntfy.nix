{self, ...}: {
  flake.modules.nixos.ntfy = {config, ...}: let
    inherit (self.services.ntfy) fqdn port;
  in {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${fqdn}";
        listen-http = "${self.hosts.${config.networking.hostName}.tailscaleIP}:${toString port}";
        upstream-base-url = "https://ntfy.sh";
        behind-proxy = true;
      };
    };
  };
}
