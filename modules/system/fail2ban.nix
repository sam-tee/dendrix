{self, ...}: {
  flake.modules.nixos = {
    default = self.modules.nixos.fail2ban;
    fail2ban = _: {
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        bantime = "1h";
        bantime-increment = {
          enable = true;
          maxtime = "48h";
        };
        ignoreIP = ["100.100.10.0/24"];
      };
    };
  };
}
