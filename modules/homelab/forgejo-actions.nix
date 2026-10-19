{
  flake.modules.nixos.forgejo-actions = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    sops.secrets."forgejo/tokenFile".owner = cfg.user;
    services.forgejo-runner = {
      package = pkgs.forgejo-runner;
      instances.default = {
        enable = true;
        settings.server.connections.default = {
          url = cfg.settings.server.ROOT_URL;
          uuid = "684bbd79-0b82-4d37-b628-80ed3a4b2ee4";
        };
        secrets.server.connections.default.token_url = config.sops.secrets."forgejo/tokenFile".path;
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
        settings.runner.labels = [
          "native:host"
          "nix:host"
        ];
      };
    };
  };
}
