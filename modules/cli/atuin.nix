{self, ...}: {
  flake.modules.generic = {
    default = self.modules.generic.atuin;
    atuin = {
      config,
      pkgs,
      username,
      ...
    }: {
      sops.secrets = {
        "atuin-key".owner = username;
        "atuin-session".owner = username;
      };
      programs.atuin = {
        enable = true;
        # timing-sensitive e2e tests that flake on darwin, like the ones nixpkgs already skips
        package =
          if pkgs.stdenv.hostPlatform.isDarwin
          then
            pkgs.atuin.overrideAttrs (old: {
              checkFlags =
                (old.checkFlags or [])
                ++ [
                  "--skip=a_diverged_copy_resumes_only_as_chosen"
                  "--skip=a_session_gone_on_with_elsewhere_catches_up_where_it_came_from"
                ];
            })
          else pkgs.atuin;
        settings = {
          auto_sync = true;
          dialect = "uk";
          inline_height = 30;
          search_mode = "fuzzy";
          show_preview = true;
          style = "compact";
          sync_address = "https://${self.services.atuin.fqdn}";
          sync_frequency = "5m";
          update_check = false;
          key_path = config.sops.secrets."atuin-key".path;
          session_path = config.sops.secrets."atuin-session".path;
        };
      };
    };
  };
}
