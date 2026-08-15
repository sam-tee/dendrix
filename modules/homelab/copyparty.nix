{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.copyparty.url = "github:9001/copyparty";
  flake.modules.nixos.copyparty = {
    config,
    pkgs,
    ...
  }: let
    cpp = inputs.copyparty;
    inherit (config.homelab) group user dataDir;
    inherit (self.services.copyparty) port;
  in {
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
        i = "0.0.0.0";
        no-reload = true;
        p = [port];
        xff-src = "100.75.222.43/32"; # oracle's tailnet IP (the only reverse proxy)
        xff-hdr = "x-forwarded-for";
        rproxy = 1;
      };
      groups = {
        admin = ["media"];
        users = ["sam" "media"];
      };
      volumes."/" = {
        path = "${dataDir}";
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
