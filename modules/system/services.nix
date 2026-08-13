{self, ...}: {
  flake.modules.nixos = {
    gui = self.modules.nixos.services;
    services = _: {
      security.rtkit.enable = true;
      services = {
        avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
            enable = true;
            userServices = true;
          };
        };
        fwupd.enable = true;
        libinput.enable = true;
        pipewire = {
          enable = true;
          alsa = {
            enable = true;
            support32Bit = true;
          };
          pulse.enable = true;
          wireplumber.enable = true;
        };
        printing.enable = true;
        pulseaudio.enable = false;
        udisks2.enable = true;
      };
    };
  };
}
