{self, ...}: {
  flake.modules.nixos = {
    default = self.modules.nixos.fail2ban;
    fail2ban = _: {
      services.fail2ban = {
        enable = true;
        maxretry = 5;
        ignoreIP = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "192.168.0.0/16"
        ];
      };
    };
  };
}
