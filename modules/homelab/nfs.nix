{
  flake.modules.nixos.nfs = _: {
    services.nfs.server = {
      enable = true;
      lockdPort = 4001;
      mountdPort = 4002;
      statdPort = 4000;
    };
    # Only expose NFS to the homelab LAN and the tailnet, never the internet.
    networking.firewall.extraInputRules = ''
      ip saddr { 192.168.0.0/16, 10.0.0.0/8, 100.64.0.0/10 } tcp dport { 111, 2049, 20048, 4000, 4001, 4002 } accept
      ip saddr { 192.168.0.0/16, 10.0.0.0/8, 100.64.0.0/10 } udp dport { 111, 2049, 20048, 4000, 4001, 4002 } accept
    '';
  };
}
