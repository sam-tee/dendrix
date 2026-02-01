{
  flake.modules.nixos.anki = {config, ...}: {
    homelab.ingress.anki = "27701";
    sops.secrets."anki/samPwd" = {};
    services.anki-sync-server = {
      address = "0.0.0.0";
      enable = true;
      openFirewall = true;
      users = [
        {
          username = "sam";
          passwordFile = config.sops.secrets."anki/samPwd".path;
        }
      ];
    };
  };
}
