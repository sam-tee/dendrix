{
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
    hl = config.homelab;
  in {
    homelab.ingress.git = "3000";
    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
    };
    services = {
      openssh.settings.AcceptEnv = "GIT_PROTOCOL";
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
            DOMAIN = "git.akhlus.uk";
            ROOT_URL = "https://git.akhlus.uk/";
            HTTP_ADDR = "0.0.0.0";
            HTTP_PORT = 3000;
            SSH_DOMAIN = "git-ssh.akhlus.uk";
            SSH_PORT = lib.head config.services.openssh.ports;
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
