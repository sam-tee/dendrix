{self, ...}: {
  flake.lib.mkTsIp = machine: self.hosts.${machine}.tailscaleIP or "0.0.0.0";
}
