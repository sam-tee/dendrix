{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  inherit (self.services.t3) port;
in {
  flake.modules = {
    nixos = {
      default = self.modules.nixos.t3;
      t3desktop = moduleWithSystem ({self', ...}: {config, ...}: {
        environment = {
          sessionVariables.T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
          systemPackages = [self'.packages.t3code-desktop-nightly];
        };
      });
      t3 = moduleWithSystem ({self', ...}: {
        config,
        username,
        ...
      }: let
        t3 = self'.packages.t3code-nightly;
        inherit (config.users.users.${username}) home;
        inherit (self.hosts.${config.networking.hostName}) tailscaleIP;
      in {
        environment = {
          sessionVariables.T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
          systemPackages = [t3];
        };
        systemd.services.t3code = {
          description = "T3 Code server (tailscale-bound, nightly)";
          after = ["network-online.target" "tailscaled.service"];
          wants = ["network-online.target"];
          wantedBy = ["multi-user.target"];
          environment = {
            T3CODE_HOME = "${config.xdg.dirs.configDir}/t3";
            FJ_FALLBACK_HOST = "https://${self.services.forgejo.fqdn}";
          };
          serviceConfig = {
            User = username;
            WorkingDirectory = home;
            ExecStart = "${lib.getExe t3} serve --host ${tailscaleIP} --port ${toString port}";
            Restart = "always";
            RestartSec = 10;
          };
        };
      });
    };

    darwin = {
      default = self.modules.darwin.t3;
      t3 = {config, ...}: let
        t3Home = "${config.xdg.dirs.configDir}/t3";
      in {
        homebrew.casks = ["t3-code@nightly"];
        environment.variables.T3CODE_HOME = t3Home;
        launchd.user.agents.t3code-env = {
          command = "/bin/launchctl setenv T3CODE_HOME ${t3Home}";
          serviceConfig.RunAtLoad = true;
        };
      };
    };
  };
}
