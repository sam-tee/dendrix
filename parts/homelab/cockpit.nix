{
  flake.modules.nixos.cockpit = _: {
    services.cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = ["https://*.akhlus.uk" "https://*.samtee.uk" "https://192.168.*.*"];
    };
  };
}
