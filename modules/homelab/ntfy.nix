{self, ...}: {
  flake.modules.nixos.ntfy = {config, ...}: let
    inherit (config.homelab) domain;
    inherit (self.services.ntfy) port subdomain;
  in {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${subdomain}.${domain}";
        listen-http = ":${toString port}";
        upstream-base-url = "https://ntfy.sh";
        behind-proxy = true;
      };
    };
  };
}
