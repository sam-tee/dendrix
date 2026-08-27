{self, ...}: {
  flake.modules.nixos.sports-notify = {config, ...}: let
    inherit (self.services.sports-notify) port;
  in {
    sops.secrets."sportsNotifyConfig" = {};
    services.sports-notify = {
      enable = true;
      inherit port;
      environmentFile = config.sops.secrets."sportsNotifyConfig".path;
      settings = {
        ntfy = {
          server = "https://ntfy.akhlus.uk";
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
