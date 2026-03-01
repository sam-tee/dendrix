{
  flake.modules.nixos.networking = _: {
    networking.networkmanager = {
      enable = true;
      unmanaged = [
        "interface-name:tailscale*"
        "type:bridge"
      ];
    };
  };
}
