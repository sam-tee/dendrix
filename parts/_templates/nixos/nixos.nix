{username, ...}: {
  #nixos configuration goes here
  nMods = {
    de.environment = "plasma";
    ssh.publicKey = "PUB_KEY";
    steam.enable = false;
  };

  home-manager.users.${username} = {
    #home config goes here
    hMods.packages = {
      ghostty.package = null;
      enableExtra = true;
    };
  };
}
