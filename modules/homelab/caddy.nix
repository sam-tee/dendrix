{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    lib,
    ...
  }: let
    inherit (lib) filterAttrs mapAttrs' nameValuePair optionalString;
    inherit (self) domain tailnet;
    inherit (config.homelab) group user;
    mkCaddyHost = _name: svc:
      nameValuePair svc.fqdn {
        useACMEHost = domain;
        extraConfig =
          optionalString (svc.tailnetOnly or false) ''
            @outside not remote_ip 100.64.0.0/10 fd7a:115c:a1e0::/48
            abort @outside
          ''
          + ''
            encode zstd gzip
            reverse_proxy http://${svc.host}.${tailnet}:${toString svc.port}
          '';
      };
    caddyHosts =
      self.services
      |> filterAttrs (_name: svc: svc.port != 0)
      |> filterAttrs (_name: svc: svc.host != "")
      |> (mapAttrs' mkCaddyHost);
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
