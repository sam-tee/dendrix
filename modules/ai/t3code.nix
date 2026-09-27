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
      t3 = inputs'.ai.packages.t3code;
    in {
      environment.systemPackages = [t3];
      systemd.services.t3code = {
        description = "T3 Code server (tailscale-bound)";
        after = ["network-online.target" "tailscaled.service"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        environment.T3CODE_BASE_DIR = "$XDG_CONFIG_HOME/t3";
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
    darwin.t3code = moduleWithSystem ({inputs', ...}: _: {
      environment.systemPackages = with inputs'.ai.packages; [t3code t3code-desktop];
    });
  };
}
