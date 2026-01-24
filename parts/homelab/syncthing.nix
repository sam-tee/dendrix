{
  flake.modules = {
    nixos.syncthing = {config, ...}: let
      inherit (config.homelab) group user;
    in {
      homelab.ingress.sync = "8384";
      sops.secrets."syncPwd".owner = user;
      services.syncthing = {
        enable = true;
        inherit user group;
        configDir = "/var/lib/media/syncthing";
        dataDir = "/var/lib/media";
        settings = {
        };
      };
      networking.firewall.allowedTCPPorts = [8384 22000];
      networking.firewall.allowedUDPPorts = [22000 21027];
    };
    homeManager.syncthing = _: {
      services.syncthing = {
        enable = true;
      };
    };
  };
}
