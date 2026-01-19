{
  flake.modules.nixos.email = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.homelab.email = {
      from = lib.mkOption {
        description = "The 'from' address";
        type = lib.types.str;
        default = "john@example.com";
      };
      host = lib.mkOption {
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
    config = let
      inherit (config.homelab.email) from host user pwdPath;
    in {
      sops.secrets.smtpPwd = {};
      homelab.email = {
        from = "noreply@akhlus.uk";
        host = "smtp-relay.brevo.com";
        user = "9fb25b001@smtp-brevo.com";
        pwdPath = config.sops.secrets.smtpPwd.path;
      };
      programs.msmtp = {
        enable = true;
        accounts.default = {
          auth = true;
          inherit from host user;
          tls = true;
          passwordeval = "${pkgs.coreutils}/bin/cat ${pwdPath}";
        };
      };
    };
  };
}
