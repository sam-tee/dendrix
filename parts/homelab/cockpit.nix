{
  flake.modules.nixos.cockpit = {
    services.cockpit = {
      enable = true;
      openFirewall = true;
      allowed-origins = ["https://*.akhlus.uk" "https://*.samtee.uk" "https://192.168.*.*"];
      settings.WebService.AllowUnencrypted = true;
    };
  };
}
