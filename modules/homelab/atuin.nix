{
  flake.modules = {
    nixos.atuin = {config, ...}: let
      inherit (config.homelab) domain;
    in {
      services = {
        caddy.virtualHosts."atuin.${domain}" = {
          useACMEHost = domain;
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8888
          '';
        };
        atuin = {
          enable = true;
          openFirewall = true;
          openRegistration = false;
        };
      };
    };
    homeManager.cli = {config, ...}: {
      sops.secrets = {
        "atuin/key" = {};
        "atuin/session" = {};
      };
      programs.atuin = {
        enable = true;
        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "https://atuin.akhlus.uk";
          search_mode = "prefix";
          key_path = config.sops.secrets."atuin/key".path;
          session_path = config.sops.secrets."atuin/session".path;
        };
      };
    };
  };
}
