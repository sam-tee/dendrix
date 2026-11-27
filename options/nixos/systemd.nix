{
  flake.modules.nixos.default = {lib, ...}: let
    inherit (lib) mkIf mkOption;
    inherit (lib.types) attrsOf bool submodule;
  in {
    options.systemd.services = mkOption {
      type = attrsOf (submodule ({config, ...}: {
        options.waitForTailscaleIP = mkOption {
          type = bool;
          default = false;
          description = ''
            Start this service only once the host's tailscale IP is assigned
            to the tailscale interface, for services that bind that address.
          '';
        };
        config = mkIf config.waitForTailscaleIP {
          after = ["tailscale-ip.service"];
          wants = ["tailscale-ip.service"];
        };
      }));
    };
  };
}
