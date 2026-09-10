{self, ...}: let
  hostname = "duet";
in {
  flake = {
    hosts.${hostname} = {
      username = "sam";
      system = "lenovo-krane";
      hostType = "nixos";
      pubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKLSs9wmp3rSRPnantmeWXdf8G0QNGmNL56Sq0x36FO";
      syncID = "SJNAPIL-22LWU3G-KZEQOEI-XNR3UVI-C2OGLRZ-4AKYSWI-J76CS2M-PVTADQT";
    };

    nixosConfigurations = self.lib.mkMobile hostname;

    modules.nixos.${hostname} = {pkgs, ...}: {
      imports = with self.modules.nixos; [
        autologin
        gdm
        gnome
        helium
      ];
      environment.systemPackages = with pkgs; [
        foliate
        gnomeExtensions.screen-rotate
      ];
    };
  };
}
