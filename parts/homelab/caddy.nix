{
  flake.modules.nixos.homelab = {config, ...}: let
    inherit (config.homelab) domain;
  in {
    sops.secrets."cloudflareAPI" = {};
    security.acme = {
      acceptTerms = true;
      defaults.email = "sam@akhlus.uk";
      certs.${domain} = {
        reloadServices = ["caddy.service"];
        inherit domain;
        extraDomainNames = ["*.${domain}"];
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
        group = config.services.caddy.group;
        environmentFile = config.sops.secrets.cloudflareAPI.path;
      };
    };
    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
