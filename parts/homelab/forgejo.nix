{
  flake.modules.nixos.forgejo = {
    config,
    lib,
    ...
  }: {
    services.openssh.settings.AcceptEnv = "GIT_PROTOCOL";
    services.forgejo = {
      enable = true;
      stateDir = "/var/lib/media/git";
      group = "media";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "localhost";
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
}
