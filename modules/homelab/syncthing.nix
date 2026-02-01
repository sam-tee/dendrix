let
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
in {
  flake.modules = {
    nixos.syncthing = {config, ...}: let
      inherit (config.homelab) domain group user;
    in {
      sops.secrets."syncPwd".owner = user;
      services = {
        caddy.virtualHosts."sync.${domain}" = {
          useACMEHost = domain;
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8384
          '';
        };
        syncthing = {
          enable = true;
          inherit user group;
          configDir = "/var/lib/media/syncthing";
          dataDir = "/var/lib/media";
          guiAddress = "0.0.0.0:8384";
          openDefaultPorts = true;
          guiPasswordFile = config.sops.secrets."syncPwd".path;
          settings = {
            gui.user = "sam";
            inherit devices folders;
          };
        };
      };
    };
    homeManager.syncthing = _: {
      services.syncthing = {
        enable = true;
        settings = {inherit devices folders;};
      };
    };
  };
}
