{
  flake.modules.nixos.networking = _: {
    networking.networkmanager.enable = true;
  };
}
