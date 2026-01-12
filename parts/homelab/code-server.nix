{
  flake.modules.nixos.code-server = {config, ...}: let
    cfg = config.homelab;
  in {
    networking.firewall.allowedTCPPorts = [4444];
    services.code-server = {
      enable = true;
      inherit (cfg) group user;
      hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$NFNaZnQyd0hpYzhPN3NYdlRGZHZlTzIwbjlNPQ$7RPhiHoXyvGq+FILur5+PYdEBjk3EHhkdrV/YPR6Q6Q";
      userDataDir = "/var/lib/media/code";
      extensionsDir = "/var/lib/media/code/extensions";
    };
  };
}
