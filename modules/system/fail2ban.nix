{self, ...}: {
  flake.modules.nixos = {
    default = self.modules.nixos.fail2ban;
    fail2ban = _: {
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        bantime = "1h";
        ignoreIP = ["127.0.0.0/8"];
      };
    };
  };
}
