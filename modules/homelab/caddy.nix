{
  flake.modules.nixos.homelab = {config, ...}: let
    inherit (config.homelab) domain group user;
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
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        group = config.services.caddy.group;
        environmentFile = config.sops.secrets.cloudflareAPI.path;
      };
    };
    services.caddy = {
      enable = true;
      inherit group user;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts."*.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          respond "Not Found" 404
        '';
      };
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
