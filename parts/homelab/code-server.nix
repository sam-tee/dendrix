{
  flake.modules.nixos.code-server = {config, ...}: {
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."code.akhlus.uk" = "http://localhost:4444";
      code-server = {
        enable = true;
        group = "media";
        hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$NFNaZnQyd0hpYzhPN3NYdlRGZHZlTzIwbjlNPQ$7RPhiHoXyvGq+FILur5+PYdEBjk3EHhkdrV/YPR6Q6Q";
        userDataDir = "/var/lib/media/code";
      };
    };
  };
}
