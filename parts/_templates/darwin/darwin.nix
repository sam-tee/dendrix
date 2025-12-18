{username, ...}: {
  #darwin configuration goes here
  dMods.ssh.publicKey = "";

  home-manager.users.${username} = {
    #home config goes here
    hMods.packages = {
      ghostty.package = null;
      enableExtra = true;
    };
  };
}
