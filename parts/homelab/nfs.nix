{
  flake.modules.nixos.nfs = {
    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };
    networking.firewall = let
      ports = [111 2049 4000 4001 4002 20048];
    in {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };
  };
}
