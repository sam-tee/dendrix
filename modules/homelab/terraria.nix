{
  flake.modules.nixos.terraria = {config, ...}: {
    sops.secrets."terraria/serverPwd" = {};
    services.terraria = {
      enable = true;
      openFirewall = true;
      dataDir = "/var/lib/media/terraria";
      password = config.sops.secrets."terraria/serverPwd".path;
      worldPath = "/var/lib/media/terraria/u410_Test.wld";
    };
  };
}
