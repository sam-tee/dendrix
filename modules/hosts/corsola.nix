{
  lib,
  self,
  ...
}: let
  inherit (lib) mkAfter singleton;
  hostname = "corsola";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "asus-tentacruel";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILM24PrL2MDQryUHOHlYn1hU/F61eqCh1PuEgi34gzLn";
      syncID = "";
      tailscaleIP = "";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {...}: {
      imports = with self.modules.nixos; [
        hyprland
        gui
      ];
      hjem.extraModules = singleton {
        xdg.config.files."hypr/hyprland.lua".text = mkAfter ''
          hl.monitor({output="eDP-1", scale=1, mode="1920x1080@60.00Hz"})
        '';
      };
      swapDevices = singleton {
        device = "/swapfile";
        size = 4 * 1024;
      };
    };
  };
}
