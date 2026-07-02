{self, ...}: {
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
    hl = config.homelab;
    sshPort = lib.head config.services.openssh.ports;
    inherit (self.services.forgejo) port subdomain;
    domain = "${subdomain}.${hl.domain}";
  in {
    imports = [self.modules.nixos.forgejo-actions];

    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
    };
    services.openssh.settings.AcceptEnv = ["GIT_PROTOCOL"];
    services.forgejo = {
      enable = true;
      stateDir = "${hl.dataDir}/git";
      lfs.enable = true;
      database.type = "postgres";
      settings = {
        mailer = {
          ENABLED = true;
          FROM = hl.email.from;
          PROTOCOL = "sendmail";
          SENDMAIL_PATH = "/run/wrappers/bin/sendmail";
        };
        repository = {
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };
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
        };
        log.LEVEL = "Trace";
      };
    };
    systemd.services.forgejo.preStart = ''
      ${lib.getExe cfg.package} admin user create --admin --email "root@localhost" --username root --password "$(tr -d '\n' < ${config.sops.secrets."forgejo/adminPwd".path})" || true
    '';
  };
}
