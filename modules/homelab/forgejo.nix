{self, ...}: {
  flake.modules.nixos.forgejo = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.forgejo;
    hl = config.homelab;
    inherit (lib) getExe getExe';
    inherit (hl) caddyIP email machineIP;
    inherit (self.services.forgejo) fqdn port;
  in {
    imports = with self.modules.nixos; [forgejo-actions forgejo-templates forgejo-theme];

    sops.secrets = {
      "forgejo/adminPwd".owner = cfg.user;
      "forgejo/databasePwd".owner = cfg.database.user;
      smtpPwd.owner = cfg.user;
      "forgejo/signingKey" = {
        owner = cfg.user;
        restartUnits = ["forgejo.service"];
      };
      "forgejo/signingKey.pub" = {
        owner = cfg.user;
        mode = "0444";
        restartUnits = ["forgejo.service"];
      };
    };
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
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
        "repository.signing" = {
          FORMAT = "ssh";
          SIGNING_KEY = config.sops.secrets."forgejo/signingKey.pub".path;
          SIGNING_NAME = "Forgejo";
          SIGNING_EMAIL = "noreply@${fqdn}";
          MERGES = "pubkey";
        };
        "git.config"."gpg.ssh.program" = getExe' pkgs.openssh "ssh-keygen";
        actions.ENABLED = true;
        cron.ENABLED = true;
        server = {
          DOMAIN = fqdn;
          ROOT_URL = "https://${fqdn}/";
          HTTP_ADDR = machineIP;
          HTTP_PORT = port;
          LANDING_PAGE = "/sam-tee";
          SSH_PORT = 22;
          SSH_DOMAIN = fqdn;
          DISABLE_SSH = false;
        };
        service = {
          DISABLE_REGISTRATION = true;
          ENABLE_NOTIFY_MAIL = true;
          REGISTER_EMAIL_CONFIRM = true;
          DEFAULT_KEEP_EMAIL_PRIVATE = true;
        };
        security.REVERSE_PROXY_TRUSTED_PROXIES = "${caddyIP}/32,127.0.0.1/32,::1/128";
      };
    };
    services.openssh.settings.AllowUsers = [cfg.user];
    systemd.services.forgejo.preStart = ''
      ${getExe cfg.package} admin user create --admin --email "root@localhost" --username root --password "$(tr -d '\n' < ${config.sops.secrets."forgejo/adminPwd".path})" || true
    '';
  };
}
