{
  flake.modules.nixos.code-server = {config, ...}: let
    inherit (config.homelab) domain group user;
  in {
    networking.firewall.allowedTCPPorts = [4444];
    services = {
      caddy.virtualHosts."code.${domain}" = {
        useACMEHost = domain;
        extraConfig = ''
          reverse_proxy http://127.0.0.1:4444
        '';
      };
      code-server = {
        enable = true;
        inherit group user;
        hashedPassword = "$argon2i$v=19$m=4096,t=3,p=1$NFNaZnQyd0hpYzhPN3NYdlRGZHZlTzIwbjlNPQ$7RPhiHoXyvGq+FILur5+PYdEBjk3EHhkdrV/YPR6Q6Q";
        userDataDir = "/var/lib/media/code";
        extensionsDir = "/var/lib/media/code/extensions";
      };
    };
  };
}
