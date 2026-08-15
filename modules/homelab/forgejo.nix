{self, ...}: {
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
    hl = config.homelab;
    inherit (hl) email;
    sshPort = lib.head config.services.openssh.ports;
    inherit (self.services.forgejo) port subdomain;
    domain = "${subdomain}.${hl.domain}";
  in {
    imports = [self.modules.nixos.forgejo-actions];

    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
      smtpPwd.owner = cfg.user;
    };
    services.openssh.settings.AcceptEnv = ["GIT_PROTOCOL"];
    services.forgejo = {
      enable = true;
      stateDir = "${hl.dataDir}/git";
      lfs.enable = true;
      database.type = "postgres";
      secrets.mailer.PASSWD = config.sops.secrets.smtpPwd.path;
      settings = {
        mailer = {
          ENABLED = true;
          FROM = "Forgejo <${email.from}>";
          PROTOCOL = "smtps";
          SMTP_ADDR = email.host;
          SMTP_PORT = 465;
          USER = email.user;
        };
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
        actions.ENABLED = true;
        cron.ENABLED = true;
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "0.0.0.0";
          HTTP_PORT = port;
          LANDING_PAGE = "/sam-tee";
          SSH_PORT = sshPort;
          SSH_DOMAIN = "git-ssh.${hl.domain}";
          DISABLE_SSH = false;
        };
        service = {
          DISABLE_REGISTRATION = true;
          ENABLE_NOTIFY_MAIL = true;
          REGISTER_EMAIL_CONFIRM = true;
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
        };
        log.LEVEL = "Info";
      };
    };
    systemd.services.forgejo.preStart = ''
      ${lib.getExe cfg.package} admin user create --admin --email "root@localhost" --username root --password "$(tr -d '\n' < ${config.sops.secrets."forgejo/adminPwd".path})" || true
    '';
  };
}
