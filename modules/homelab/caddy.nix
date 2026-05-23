{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    lib,
    ...
  }: let
    inherit (config.homelab) domain group user;
    mkCaddyHost = _name: svc: let
      prefix =
        if svc.private
        then "ts."
        else "";
      fqdn = "${svc.subdomain}.${prefix}${domain}";
    in
      lib.nameValuePair fqdn {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://${svc.host}:${toString svc.port}
        '';
      };
    caddyHosts =
      self.services
      |> lib.filterAttrs (_name: svc: svc.subdomain or "" != "")
      |> lib.filterAttrs (_name: svc: svc.host or "" != "")
      |> (lib.mapAttrs' mkCaddyHost);
  in {
    sops.secrets."cloudflareAPI" = {};
    security.acme = {
      acceptTerms = true;
      defaults.email = "sam@akhlus.uk";
      certs.${domain} = {
        reloadServices = ["caddy.service"];
        inherit domain;
        extraDomainNames = ["*.${domain}" "*.ts.${domain}"];
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
