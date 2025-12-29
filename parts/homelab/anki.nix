{
  flake.modules.nixos.anki = {config, ...}: {
    sops.secrets."anki/sam" = {};
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."anki.akhlus.uk" = "http://localhost:27701";
      anki-sync-server = {
        enable = true;
        openFirewall = true;
        baseDirectory = "/var/lib/media/anki";
        users = [
          {
            username = "sam";
            passwordFile = config.sops.secrets."anki/sam".path;
          }
        ];
      };
    };
  };
}
