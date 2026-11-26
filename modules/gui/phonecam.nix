{inputs, ...}: {
  flake.modules.nixos.phonecam = {username, ...}: {
    imports = [inputs.phonecam.nixosModules.default];
    services.phonecam = {
      enable = true;
      users = [username];
    };
  };
}
