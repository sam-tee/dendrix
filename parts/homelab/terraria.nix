{
  flake.modules.nixos.terraria = {
    services = {
      terraria = {
        enable = true;
        openFirewall = true;
        dataDir = "/var/lib/media/terraria";
        password = "TerrariaTest123";
        worldPath = "/var/lib/media/terraria/u410_Test.wld";
      };
    };
  };
}
