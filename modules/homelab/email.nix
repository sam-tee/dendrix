{
  flake.modules.nixos.email = {
    config,
    pkgs,
    ...
  }: let
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
}
