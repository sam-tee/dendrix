self: {
  flake.modules.nixos.server = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe;
    checkClean = pkgs.writeShellApplication {
      name = "disk-clean-check";
      runtimeInputs = with pkgs; [coreutils];
      text = ''
        usage=$(df --output=pcent / | tail -n 1 | tr -dc '0-9')
        if [ -z "$usage" ]; then
          echo "disk-clean: failed to parse 'df' output for /" >&2
          exit 1
        fi
        if [ "$usage" -ge 90 ]; then
          echo "disk-clean: / at ''${usage}% (>= 90%), running 'nhw clean'"
          exec ${getExe self.packages.${pkgs.stdenv.hostPlatform.system}.nhw} clean
        else
          echo "disk-clean: / at ''${usage}% (< 90%), skipping"
        fi
      '';
    };
  in {
    systemd.services.disk-clean = {
      description = "Run nhw clean when / exceeds 90%";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = getExe checkClean;
      };
    };

    systemd.timers.disk-clean = {
      description = "Check / usage hourly, clean when above 90%";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "15min";
        OnUnitActiveSec = "1h";
        Unit = "disk-clean.service";
      };
    };
  };
}
