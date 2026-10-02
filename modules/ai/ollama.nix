_: {
  flake.modules.nixos.ollama = {
    config,
    pkgs,
    ...
  }: {
    users.users.ollama = {
      isSystemUser = true;
      group = "ollama";
      home = config.services.ollama.home;
      extraGroups = ["video" "render"];
    };
    users.groups.ollama = {};
    services.ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
      user = "ollama";
      group = "ollama";
      host = "127.0.0.1";
      port = 11434;
      openFirewall = false;
      loadModels = [];
    };
    environment.systemPackages = [config.services.ollama.package];
  };
}
