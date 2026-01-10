{
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
    };
    services = {
      openssh.settings.AcceptEnv = "GIT_PROTOCOL";
      forgejo = {
        enable = true;
        database = {
          type = "postgres";
          passwordFile = config.sops.secrets."forgejo/databasePwd".path;
        };
        stateDir = "/var/lib/media/git";
        group = "media";
        lfs.enable = true;
        settings = {
          log.LEVEL = "Trace";
          mailer = {
            ENABLED = true;
            FROM = config.homelab.email.from;
            PROTOCOL = "sendmail";
            SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
          };
          server = {
            DOMAIN = "git.akhlus.uk";
            ROOT_URL = "https://git.akhlus.uk/";
            HTTP_ADDR = "0.0.0.0";
            HTTP_PORT = 3000;
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
      user = "root";
    in ''
      ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
    '';
  };
}
