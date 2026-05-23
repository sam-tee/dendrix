{
  flake.modules.nixos.vms = {username, ...}: {
    virtualisation = {
      spiceUSBRedirection.enable = true;
      libvirtd.enable = true;
    };
    programs.virt-manager.enable = true;
    users.users.${username}.extraGroups = ["libvirtd"];
  };
}
