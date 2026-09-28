{
  lib,
  moduleWithSystem,
  self,
  ...
}: let
  port = 3773;
  serveCommand = t3: tailscaleIP: "${lib.getExe t3} serve --host ${tailscaleIP} --port ${toString port}";
  tailscaleIPFor = config: self.hosts.${config.networking.hostName}.tailscaleIP;
in {
  flake.modules = {
    nixos.default = self.modules.nixos.t3code;
    nixos.t3code = moduleWithSystem ({self', ...}: {
      config,
      username,
      ...
    }: let
      t3 = self'.packages.t3code-slim;
      home = config.users.users.${username}.home;
    in {
      environment.systemPackages = [t3];
      systemd.services.t3code = {
        description = "T3 Code server (tailscale-bound)";
        after = ["network-online.target" "tailscaled.service"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        # systemd Environment= does no shell expansion, so $HOME would be
        # literal here — use the Nix-interpolated absolute home instead.
        environment.T3CODE_HOME = "${home}/.config/t3";
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
    darwin.t3code = moduleWithSystem ({self', ...}: {
      config,
      username,
      ...
    }: let
      t3 = self'.packages.t3code-slim;
      home = config.users.users.${username}.home;
      t3code-desktop-slim = self'.packages.t3code-desktop-slim;
    in {
      environment = {
        # Shell-evaluated, so $HOME correctly expands per-user at runtime.
        variables.T3CODE_HOME = "$HOME/.config/t3";
        systemPackages = [t3 t3code-desktop-slim];
      };
      launchd.user.agents.t3code = {
        command = serveCommand t3 (tailscaleIPFor config);
        # launchd EnvironmentVariables does no shell expansion, so the
        # absolute home is required here (already the case).
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
