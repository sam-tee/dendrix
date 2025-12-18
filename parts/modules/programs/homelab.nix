{
  flake.modules.nixos.homelab = {
    services.cloudflared = {
      enable = true;
    };
  };
}
