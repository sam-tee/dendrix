{
  flake.modules = {
    nixos.hyprland = {
    };
    homeManager.hyprland = {lib, ...}: {
      options.hypr = {
        monitors = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [",preferred,auto,1"];
          example = ["eDP-1,1920x1080@60,auto,1"];
          description = "Monitor setup for hyprland - see Hyprland docs for options";
        };
      };
    };
  };
}
