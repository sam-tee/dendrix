let
  devices = {
    a3.id = "GITF6T5-Q23HCQ6-SBMP3ZC-J77WSL4-BBNHO2U-6C2L2XA-GVJ2FWQ-RERKCQH";
    duet3.id = "LVSIHL6-LFUENR2-KX22SIV-TMVCDWF-3RSQAZJ-ACD5DHB-ATHYI2E-GW63LAQ";
    mba.id = "OBTLFOZ-UTYW6JE-3MDA6YU-YXOZPEI-62JF23C-EAII64O-TSBIVZG-TBARUQX";
    s340.id = "7Z2QWJX-7FGBQRR-NTSJKT4-NYXLPX2-PYFARFH-WRAB5NS-DXQU64N-P3FBEAF";
    u410.id = "UTMRHSO-5UGRFRV-6WMVUQR-N4B47H6-3AYB7NI-3YGFPEI-E3U42S3-VLCKWAN";
  };
  folders = {
    books = {
      path = "~/books";
      devices = ["a3" "u410" "s340"];
      ignorePatterns = ["(?d).DS_Store"];
    };
    calibre_config = {
      path = "~/.config/calibre";
      devices = ["a3" "u410" "s340"];
      ignorePatterns = ["(?d).DS_Store"];
    };
    Docs = {
      path = "~/Documents";
      devices = ["a3" "duet3" "mba" "s340" "u410"];
      ignorePatterns = ["(?d).DS_Store" ".venv" "result"];
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
