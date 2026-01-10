{
  flake.modules.nixos.email = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homelab.email;
  in {
    options.homelab.email = {
      from = lib.mkOption {
        description = "The 'from' address";
        type = lib.types.str;
        default = "john@example.com";
      };
      server = lib.mkOption {
        description = "The SMTP server address";
        type = lib.types.str;
        default = "smtp.example.com";
      };
      user = lib.mkOption {
        description = "The SMTP username";
        type = lib.types.str;
        default = "john@example.com";
      };
      pwdPath = lib.mkOption {
        description = "Path to the secret containing SMTP password";
        type = lib.types.path;
      };
    };
    config = {
      sops.secrets.smtpPwd = {};
      homelab.email = {
        from = "noreplay@akhlus.uk";
        server = "smtp-relay.brevo.com";
        user = "9fb25b001@smtp-brevo.com";
        pwdPath = config.sops.secrets.smtpPwd.path;
      };
      programs.msmtp = {
        enable = true;
        accounts.default = {
          auth = true;
          host = cfg.server;
          from = cfg.from;
          user = cfg.user;
          tls = true;
          passwordeval = "${pkgs.coreutils}/bin/cat ${cfg.pwdPath}";
        };
      };
    };
  };
}
