{
  flake.modules.nixos.terraria = {config, ...}: {
    sops.secrets."terraria/serverPwd" = {};
    services.terraria = {
      enable = true;
      openFirewall = true;
      dataDir = "${config.homelab.dataDir}/terraria";
      password = config.sops.secrets."terraria/serverPwd".path;
      worldPath = "${config.homelab.dataDir}/terraria/u410_Test.wld";
    };
  };
}
