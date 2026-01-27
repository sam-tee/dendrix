{
  flake.modules.nixos.forgejo-actions = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    sops.secrets."forgejo/token".owner = cfg.user;
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        url = cfg.settings.server.ROOT_URL;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets."forgejo/token".path;
        labels = [
          "ubuntu-latest:docker://node:16-bullseye"
        ];
      };
    };
  };
}
