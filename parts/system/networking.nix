{
  flake.modules.nixos.networking = {...}: {
    networking = {
      networkmanager.enable = true;
      useNetworkd = true;
    };
  };
}
