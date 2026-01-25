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
        guiAddress = "0.0.0.0:8384";
        guiPasswordFile = config.sops.secrets."syncPwd".path;
        settings = {
          gui.user = "sam";
          devices = {
            mba.id = "OBTLFOZ-UTYW6JE-3MDA6YU-YXOZPEI-62JF23C-EAII64O-TSBIVZG-TBARUQX";
            s340.id = "QA2SIUE-GMC6AD7-OAEPXEU-RQZUYU6-7DHIXGJ-GMFNXKQ-QJUVRNO-N6EYRAL";
            u410.id = "UTMRHSO-5UGRFRV-6WMVUQR-N4B47H6-3AYB7NI-3YGFPEI-E3U42S3-VLCKWAN";
          };
          folders = {
            books = {
              path = "~/books";
              devices = ["u410" "s340"];
            };
            Docs = {
              path = "~/Documents";
              devices = ["mba" "s340" "u410"];
            };
          };
        };
      };
      networking.firewall.allowedTCPPorts = [8384 22000];
      networking.firewall.allowedUDPPorts = [22000 21027];
    };
    homeManager.syncthing = _: {
      services.syncthing = {
        enable = true;
        settings = {
          devices = {
            mba.id = "OBTLFOZ-UTYW6JE-3MDA6YU-YXOZPEI-62JF23C-EAII64O-TSBIVZG-TBARUQX";
            s340.id = "QA2SIUE-GMC6AD7-OAEPXEU-RQZUYU6-7DHIXGJ-GMFNXKQ-QJUVRNO-N6EYRAL";
            u410.id = "UTMRHSO-5UGRFRV-6WMVUQR-N4B47H6-3AYB7NI-3YGFPEI-E3U42S3-VLCKWAN";
          };
          folders = {
            books = {
              path = "~/books";
              devices = ["u410" "s340"];
            };
            Docs = {
              path = "~/Documents";
              devices = ["mba" "s340" "u410"];
            };
          };
        };
      };
    };
  };
}
