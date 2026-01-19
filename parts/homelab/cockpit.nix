{
  flake.modules.nixos.cockpit = _: {
    homelab.ingress.dash = "9090";
    services.cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = ["https://*.akhlus.uk" "https://*.samtee.uk" "https://192.168.*.*"];
    };
  };
}
