{
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
    hl = config.homelab;
    sshPort = lib.head config.services.openssh.ports;
    sshDomain = "git-ssh.${hl.domain}";
    domain = "git.${hl.domain}";
  in {
    homelab.ingress.git = "3000";
    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
    };
    services = {
      openssh.settings.AcceptEnv = "GIT_PROTOCOL";
      cloudflared.tunnels.${hl.tunnel}.ingress."git-ssh.${sshDomain}" = "ssh://localhost:${toString sshPort}";
      forgejo = {
        enable = true;
        inherit (hl) group;
        stateDir = "/var/lib/media/git";
        lfs.enable = true;
        database = {
          type = "postgres";
          passwordFile = config.sops.secrets."forgejo/databasePwd".path;
        };
        settings = {
          log.LEVEL = "Trace";
          mailer = {
            ENABLED = true;
            FROM = hl.email.from;
            PROTOCOL = "sendmail";
            SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
          };
          server = {
            DOMAIN = domain;
            ROOT_URL = "https://${domain}/";
            HTTP_ADDR = "0.0.0.0";
            HTTP_PORT = 3000;
            SSH_DOMAIN = sshDomain;
            SSH_PORT = sshPort;
          };
          service = {
            DISABLE_REGISTRATION = true;
            ENABLE_NOTIFY_MAIL = true;
            REGISTER_EMAIL_CONFIRM = true;
          };
        };
      };
    };
    systemd.services.forgejo.preStart = let
      adminCmd = "${lib.getExe cfg.package} admin user";
      pwd = config.sops.secrets."forgejo/adminPwd";
    in ''
      ${adminCmd} create --admin --email "root@localhost" --username root --password "$(tr -d '\n' < ${pwd.path})" || true
    '';
  };
}
