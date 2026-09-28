{
  lib,
  moduleWithSystem,
  self,
  ...
}: {
  flake.modules = {
    nixos.default = self.modules.nixos.t3code;
    nixos.t3code = moduleWithSystem ({inputs', ...}: {
      config,
      username,
      ...
    }: let
      port = 3773;
      tailscaleIP = self.hosts.${config.networking.hostName}.tailscaleIP;
      t3 = inputs'.ai.packages.t3code.override {
        providerPackages = [inputs'.ai.packages.opencode];
      };
    in {
      environment.systemPackages = [t3];
      systemd.services.t3code = {
        description = "T3 Code server (tailscale-bound)";
        after = ["network-online.target" "tailscaled.service"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        environment.T3CODE_HOME = "$HOME/.config/t3";
        serviceConfig = {
          User = username;
          WorkingDirectory = config.users.users.${username}.home;
          ExecStart = "${lib.getExe t3} serve --host ${tailscaleIP} --port ${toString port}";
          Restart = "always";
          RestartSec = 10;
        };
      };
    });

    darwin.default = self.modules.darwin.t3code;
    darwin.t3code = moduleWithSystem ({inputs', ...}: {
      config,
      username,
      ...
    }: let
      port = 3773;
      tailscaleIP = self.hosts.${config.networking.hostName}.tailscaleIP;
      home = config.users.users.${username}.home;
      t3code-slim = inputs'.ai.packages.t3code.override {
        providerPackages = [inputs'.ai.packages.opencode];
      };
      t3code-desktop-slim = inputs'.ai.packages.t3code-desktop.override {
        t3code = t3code-slim;
      };
    in {
      environment = {
        variables.T3CODE_HOME = "$HOME/.config/t3";
        systemPackages = [t3code-slim t3code-desktop-slim];
      };
      launchd.user.agents.t3code = {
        command = "${lib.getExe t3code-slim} serve --host ${tailscaleIP} --port ${toString port}";
        environment.T3CODE_HOME = "${home}/.config/t3";
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          WorkingDirectory = home;
        };
      };
    });
  };
}
