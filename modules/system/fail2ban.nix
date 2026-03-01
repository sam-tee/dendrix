{
  flake.modules.nixos.networking = _: {
    services.fail2ban = {
      enable = true;
      maxretry = 7;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
      ];
    };
  };
}
