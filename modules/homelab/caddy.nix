{self, ...}: {
  flake.modules.nixos.caddy = {
    config,
    lib,
    pkgs,
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
          reverse_proxy http://${svc.host}.scylla-goblin.ts.net:${toString svc.port}
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
      environmentFile = pkgs.writeText "caddyEnv" ''
        TS_PERMIT_CERT_UID = "caddy";
      '';
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
          "*.ts.${domain}" = {
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
