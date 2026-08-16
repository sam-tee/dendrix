{
  flake.modules.nixos.forgejo-actions = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    sops.secrets."forgejo/tokenFile".owner = cfg.user;
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        url = cfg.settings.server.ROOT_URL;
        name = config.networking.hostName;
        tokenFile = config.sops.secrets."forgejo/tokenFile".path;
        hostPackages = with pkgs; [
          attic-client
          bash
          coreutils
          curl
          gawk
          git
          jq
          nix
          nodejs
          openssh
        ];
        labels = [
          "native:host"
          "nix:host"
        ];
      };
    };
  };
}
