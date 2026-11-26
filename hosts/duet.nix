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
    in {
      boot.kernelParams = ["consoleblank=60"];
      systemd.tmpfiles.rules = [
        "d ${dataDir} 0755 ${user} ${group} -"
      ];
    };
  };
}
