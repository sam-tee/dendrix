{
  flake.modules.nixos.laptop-server = {
    config,
    lib,
    pkgs,
    ...
  }: let
    systemctl = "${config.systemd.package}/bin/systemctl";
    inhibitor = "ac-sleep-inhibit.service";
  in {
    services = {
      logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        IdleAction = "ignore";
      };

      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 25;
        percentageAction = 20;
        criticalPowerAction = "Suspend";
        allowRiskyCriticalPowerAction = true;
      };

      udev.extraRules = ''
        # Any charger (Mains, USB-C PD exposes USB, etc.) holds the inhibitor;
        # unplug releases it. Match on ONLINE only so no charger type is missed.
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${systemctl} --no-block start ${inhibitor}"
        SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${systemctl} --no-block stop ${inhibitor}"
      '';
    };

    systemd.services.ac-sleep-inhibit = {
      description = "Block sleep while on AC power";
      wantedBy = ["multi-user.target"];
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          "${config.systemd.package}/bin/systemd-inhibit"
          # NB: no `sleep` here, so UPower's 20% critical Suspend still goes
          # through while the inhibitor is (incorrectly) held, e.g. if the
          # AC-off udev event is missed.
          "--what=idle:handle-lid-switch:handle-suspend-key:handle-hibernate-key"
          "--who=laptop-server"
          "--why=On AC power"
          "--mode=block"
          "${pkgs.coreutils}/bin/sleep"
          "infinity"
        ];
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
