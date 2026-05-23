{self, ...}: {
  flake.modules.nixos.cockpit = _: {
    services.cockpit = {
      enable = true;
      openFirewall = true;
      inherit (self.services.cockpit) port;
      allowed-origins = ["https://*.akhlus.uk" "https://*.samtee.uk" "https://192.168.*.*"];
    };
  };
}
