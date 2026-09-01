{self, ...}: {
  flake.modules.nixos.code-server = {config, ...}: let
    inherit (config.homelab) group user;
    inherit (self.services.code-server) port;
  in {
    services.code-server = {
      enable = true;
      host = self.hosts.${config.networking.hostName}.tailscaleIP;
      inherit group user port;
      hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$NFNaZnQyd0hpYzhPN3NYdlRGZHZlTzIwbjlNPQ$7RPhiHoXyvGq+FILur5+PYdEBjk3EHhkdrV/YPR6Q6Q";
    };
  };
}
