{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.atuin;
    atuin = {
      config,
      username,
      ...
    }: {
      sops.secrets = {
        "atuin-key".owner = username;
        "atuin-session".owner = username;
      };
      programs.atuin = {
        enable = true;
        settings = {
          auto_sync = true;
          dialect = "uk";
          inline_height = 30;
          search_mode = "fuzzy";
          show_preview = true;
          style = "compact";
          sync_address = "https://atuin.akhlus.uk";
          sync_frequency = "5m";
          update_check = false;
          key_path = config.sops.secrets."atuin-key".path;
          session_path = config.sops.secrets."atuin-session".path;
        };
      };
    };
  };
}
