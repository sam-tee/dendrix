{self, ...}: {
  flake.modules.nixos = {
    server = self.modules.nixos.iperf;
    iperf = _: {services.iperf3.enable = true;};
  };
}
