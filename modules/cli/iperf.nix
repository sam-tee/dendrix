{
  flake.modules.nixos.cli = _: {
    services.iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}
