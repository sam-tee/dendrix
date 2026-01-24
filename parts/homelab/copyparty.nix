{
  flake.modules.nixos.copyparty = {
    config,
    inputs,
    pkgs,
    ...
  }: let
    cpp = inputs.copyparty;
    inherit (config.homelab) group user;
  in {
    homelab.ingress.files = "3210";
    sops.secrets = {
      "copy/samPwd".owner = user;
      "copy/mediaPwd".owner = user;
    };
    imports = [cpp.nixosModules.default];
    nixpkgs.overlays = [cpp.overlays.default];
    environment.systemPackages = [pkgs.copyparty];
    services.copyparty = {
      enable = true;
      inherit user group;
      accounts = {
        sam.passwordFile = config.sops.secrets."copy/samPwd".path;
        media.passwordFile = config.sops.secrets."copy/mediaPwd".path;
      };
      settings = {
        i = "127.0.0.1";
        no-reload = true;
        p = [3210];
      };
      groups = {
        admin = ["media"];
        users = ["sam" "media"];
      };
      volumes."/" = {
        path = "/var/lib/media";
        access = {
          rwmd = ["sam" "media"];
          a = ["media"];
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
