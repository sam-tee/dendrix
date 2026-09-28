{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  port = 3773;
  t3codeHome = "$HOME/.config/t3";
  mkT3code = inputs':
    inputs'.ai.packages.t3code.override {
      providerPackages = [inputs'.ai.packages.opencode];
    };
  serveCommand = t3: tailscaleIP: "${lib.getExe t3} serve --host ${tailscaleIP} --port ${toString port}";
  tailscaleIPFor = config: self.hosts.${config.networking.hostName}.tailscaleIP;
in {
  flake.modules = {
    nixos.default = self.modules.nixos.t3code;
    nixos.t3code = moduleWithSystem ({inputs', ...}: {
      config,
      username,
      ...
    }: let
      t3 = mkT3code inputs';
      home = config.users.users.${username}.home;
    in {
      environment.systemPackages = [t3];
      systemd.services.t3code = {
        description = "T3 Code server (tailscale-bound)";
        after = ["network-online.target" "tailscaled.service"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        environment.T3CODE_HOME = t3codeHome;
        serviceConfig = {
          User = username;
          WorkingDirectory = home;
          ExecStart = serveCommand t3 (tailscaleIPFor config);
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
      t3 = mkT3code inputs';
      home = config.users.users.${username}.home;
      t3code-desktop-slim = inputs'.ai.packages.t3code-desktop.override {
        t3code = t3;
      };
    in {
      environment = {
        variables.T3CODE_HOME = t3codeHome;
        systemPackages = [t3 t3code-desktop-slim];
      };
      launchd.user.agents.t3code = {
        command = serveCommand t3 (tailscaleIPFor config);
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
