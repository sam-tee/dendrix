# Flake for install on mobile device

Uses the nixos-mobile repo at https:/github.com/nixos-mobile/nixos-mobile

## Setup guide for nixos-mobile
1. Unlock bootloader
2. Clone the nixos-mobile repo
3. Move the local.nix file into the nixos-mobile folder and replace the capitalised values
4. Run ` nix-build --argstr device device_name -A outputs.default `
5. Flash the resulting image to a usb drive
6. Use `lsblk` to find the device name of the internal storage
7. Run `dd if=/path/to/img of=/dev/blk_name status=progress` to flash to internal storage
8. You now have a nixos system!

## Post install notes
mobile-nixos seems to want to recompile the kernel everytime you run nixos-rebuild so use the home-manager config to update apps without changing base system
