{
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.forgejo;
  in {
    sops.secrets."foregjo/adminPwd".owner = cfg.user;
    services = {
      openssh.settings.AcceptEnv = "GIT_PROTOCOL";
      forgejo = {
        enable = true;
        stateDir = "/var/lib/media/git";
        group = "media";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = "git.akhlus.uk";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = 3000;
            SSH_PORT = lib.head config.services.openssh.ports;
          };
          service = {
            DISABLE_REGISTRATION = true;
            ENABLE_NOTIFY_MAIL = true;
            REGISTER_EMAIL_CONFIRM = true;
          };
          log.LEVEL = "Trace";
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
