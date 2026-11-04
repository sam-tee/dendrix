{self, ...}: {
  flake.modules.nixos.nix-pr = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (self.services.nix-pr) port;
    tracker = self.packages.${pkgs.stdenv.hostPlatform.system}.nixpkgs-pr-tracker;
  in {
    systemd.services.nixpkgs-pr-tracker = {
      description = "Notify ntfy when tracked nixpkgs PRs reach nixpkgs-unstable";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        HOST = config.homelab.machineIP;
        PORT = toString port;
        BRANCH = "nixpkgs-unstable";
        INTERVAL = toString (30 * 60);
        STATE_FILE = "/var/lib/nixpkgs-pr-tracker/state.json";
        NTFY_SERVER = "https://${self.services.ntfy.fqdn}";
        NTFY_TOPIC = "nixpkgs";
      };
      serviceConfig = {
        ExecStart = "${lib.getExe tracker}";
        DynamicUser = true;
        StateDirectory = "nixpkgs-pr-tracker";
        Restart = "always";
        RestartSec = 30;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
      };
    };
  };
}
