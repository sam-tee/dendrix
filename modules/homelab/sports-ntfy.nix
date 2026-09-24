{self, ...}: {
  flake.modules.nixos.sports-ntfy = {config, ...}: let
    inherit (self.services.ntfy) fqdn;
  in {
    sops.secrets."sportsNtfyEnv" = {};
    services.sports-ntfy = {
      enable = true;
      environmentFile = config.sops.secrets."sportsNtfyEnv".path;
      settings = {
        ntfy = {
          server = "https://${fqdn}";
          topic = "gameday";
          priority = "default";
        };
        poll.interval_seconds = 30;
        football.teams = ["*"];
        baseball.teams = ["SEA"];
        am_football.teams = ["MIN" "SEA"];
        fpl.enabled = true;
        hockey.teams = ["SEA"];
        pwhl.teams = ["Seattle"];
        basketball.teams = [];
        dulwich = {
          enabled = true;
          team_name = "Dulwich Hamlet";
          league_url = "https://www.footballwebpages.co.uk/isthmian-football-league-premier-division";
        };
      };
    };
  };
}
