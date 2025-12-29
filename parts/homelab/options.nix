{
  flake.modules.nixos.homelab = {lib, ...}: {
    options.cloudflared = {
      tunnel = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "00000000-0000-0000-0000-000000000000";
        description = "ID of tunnel";
      };
    };
  };
}
