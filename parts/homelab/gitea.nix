{
  flake.modules.nixos.gitea = {config, ...}: {
    sops.secrets."gitea/database" = {};
    services = {
      cloudflared.tunnels.${config.cloudflared.tunnel}.ingress."git.akhlus.uk" = "http://localhost:3306";
      gitea = {
        enable = true;
        group = "media";
        repositoryRoot = "/var/lib/media/code";
        stateDir = "/var/lib/media/gitea";
        database.passwordFile = config.sops.secrets."gitea/database".path;
      };
    };
  };
}
