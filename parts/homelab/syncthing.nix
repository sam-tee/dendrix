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
        guiAddress = "0.0.0.0";
        guiPasswordFile = config.sops.secrets."syncPwd";
        settings = {
          devices = {
            u410 = {id = "233WQCM-C6ZS2DI-ZFZK33B-XNXG2HQ-7WCPO7A-KL7HV52-WA4QRGX-Z3ALBA6";};
            s340 = {id = "QA2SIUE-GMC6AD7-OAEPXEU-RQZUYU6-7DHIXGJ-GMFNXKQ-QJUVRNO-N6EYRAL";};
          };
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
