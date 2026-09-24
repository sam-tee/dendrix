{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) domain group user tailnetDomain;
    mkCaddyHost = _name: svc:
      lib.nameValuePair svc.fqdn {
        useACMEHost = domain;
        extraConfig = ''
          encode zstd gzip
          reverse_proxy http://${svc.host}.${tailnetDomain}:${toString svc.port}
        '';
      };
    caddyHosts =
      self.services
      |> lib.filterAttrs (_name: svc: svc.port != 0)
      |> lib.filterAttrs (_name: svc: svc.host != "")
      |> (lib.mapAttrs' mkCaddyHost);
  in {
    sops.secrets."cloudflareAPI" = {};
    security.acme = {
      acceptTerms = true;
      defaults.email = "sam@${self.domain}";
      certs.${domain} = {
        reloadServices = ["caddy.service"];
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
        auto_https disable_certs
      '';
      virtualHosts =
        caddyHosts
        // {
          "*.${domain}" = {
            useACMEHost = domain;
            extraConfig = ''
              respond "Not Found" 404
            '';
          };
        };
    };
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
