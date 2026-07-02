{self, ...}: {
  flake.modules.nixos.atticd = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.homelab) domain;
    inherit (self.services.atticd) port subdomain;
  in {
    sops.secrets."atticd-env" = {};

    services.atticd = {
      enable = true;
      environmentFile = config.sops.secrets."atticd-env".path;
      settings = {
        listen = "0.0.0.0:${toString port}";
        api-endpoint = "https://${subdomain}.${domain}/";
      };
    };

    environment.systemPackages = [pkgs.attic-client];
    networking.firewall.allowedTCPPorts = [port];
  };
}
