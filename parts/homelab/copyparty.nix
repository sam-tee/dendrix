{
  flake.modules.nixos.copyparty = {
    config,
    inputs,
    pkgs,
    ...
  }: let
    cpp = inputs.copyparty;
    cfg = config.homelab;
  in {
    sops.secrets = {
      "copy/samPwd" = {};
      "copy/mediaPwd" = {};
    };
    imports = [cpp.nixosModules.default];
    nixpkgs.overlays = [cpp.overlays.default];
    environment.systemPackages = [pkgs.copyparty];
    services.copyparty = {
      enable = true;
      inherit (cfg) user group;
      accounts = {
        sam.passwordFile = config.sops.secrets."samPwd";
        media.passwordFile = config.sops.secrets."mediaPwd";
      };
      groups = {
        admin = ["media"];
        users = ["sam" "media"];
      };
      volumes."/" = {
        path = "/var/lib/media";
        access = {
          rwmd = ["sam" "media"];
          a = ["admin"];
        };
        flags = {
          fk = 4;
          scan = 60;
          e2d = true;
        };
      };
    };
  };
}
