_: let
  hostname = "duet";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-krane";
      hostType = "mobile";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKLSs9wmp3rSRPnantmeWXdf8G0QNGmNL56Sq0x36FO";
      syncID = "SJNAPIL-22LWU3G-KZEQOEI-XNR3UVI-C2OGLRZ-4AKYSWI-J76CS2M-PVTADQT";
      tailscaleIP = "100.100.10.97";
      autoDeploy = true;
      modules = ["server" "laptop-server"];
    };

    modules.nixos.${hostname} = {config, ...}: let
      inherit (config.homelab) dataDir group user;
      led = "/sys/class/leds/chromeos:multicolor:charging";
      # Per-channel intensity (red green blue), each 0-7: the EC's max_brightness.
      runningColour = "4 0 7";
    in {
      boot.kernelParams = ["consoleblank=60"];
      systemd.tmpfiles.rules = [
        "d ${dataDir} 0755 ${user} ${group} -"
      ];

      # Started from udev because leds_cros_ec loads late, after multi-user.target can be reached.
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="leds", KERNEL=="chromeos:multicolor:charging", TAG+="systemd", ENV{SYSTEMD_WANTS}+="running-led.service"
      '';

      systemd.services.running-led = {
        description = "Show that the system is running on the charging LED, since the screen is broken";
        wantedBy = ["multi-user.target"];
        unitConfig.ConditionPathExists = led;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          echo ${runningColour} > ${led}/multi_intensity
          echo default-on > ${led}/trigger
        '';
        # Handing the LED back to the EC means it reverts to charge status once powered off.
        preStop = ''
          echo chromeos-auto > ${led}/trigger
        '';
      };
    };
  };
}
