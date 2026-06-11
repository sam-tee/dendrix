{self, ...}: {
  flake.modules.nixos.stirling = {config, ...}: let
    inherit (config.homelab) dataDir email;
  in {
    sops.secrets.stirling = {};
    services.stirling-pdf = {
      enable = true;
      environment = {
        PUID = config.users.users.media.uid;
        PGID = config.users.groups.media.gid;
        SECURITY_ENABLELOGIN = true;
        LANGS = "en_GB";
        SYSTEM_DEFAULTLOCALE = "en-GB";
        MAIL_ENABLED = true;
        MAIL_FROM = email.from;
        MAIL_HOST = email.host;
        MAIL_PORT = 587;
        MAIL_USERNAME = email.user;
        MAIL_TLS_ENABLED = true;
        UI_LOGOSTYLE = "modern";
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = true;
        SERVER_PORT = self.services.stirling.port;
        STORAGE_ENABLED = true;
        STORAGE_PROVIDER = "local";
        STORAGE_LOCAL_BASEPATH = "${dataDir}/stirling";
        STORAGE_SHARING_ENABLED = true;
        STORAGE_SHARING_LINKENABLED = true;
        STORAGE_SHARING_EMAILENABLED = true;
        STORAGE_SHARING_LINKEXPIRATIONDAYS = 3;
      };
      environmentFiles = [config.sops.secrets.stirling.path];
    };
  };
}
