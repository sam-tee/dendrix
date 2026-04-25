{
  flake.modules.nixos.vms = {config, ...}: {
    virtualisation = {
      spiceUSBRedirection.enable = true;
      libvirtd.enable = true;
    };
    programs.virt-manager.enable = true;
    users.users.${config.host.username}.extraGroups = ["libvirtd"];
  };
}
