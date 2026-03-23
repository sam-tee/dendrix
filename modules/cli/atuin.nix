{
  flake.modules.homeManager.cli = {config, ...}: {
    sops.secrets = {
      "atuin-key" = {};
      "atuin-session" = {};
    };
    programs.atuin = {
      enable = true;
      settings = {
        dialect = "uk";
        show_preview = true;
        inline_height = 30;
        style = "compact";
        update_check = false;
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://atuin.akhlus.uk";
        key_path = config.sops.secrets."atuin-key".path;
        session_path = config.sops.secrets."atuin-session".path;
      };
    };
  };
}
