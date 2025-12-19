# Dendritic nix flake
Uses flake-parts to make every file under parts/ a module
Available modules are:

## Nixos
- boot: systemd bootloader
- calibre: calibre web and server installs for homelab
- cli: collection of useful cli tools (see /parts/programs/cli)
- gnome: Gnome desktop environment config
- hm: sets up home-manager
- nautilis: Gnome file manager setup
- networking: networking config
- plasma: KDE setup
- services: sets up services for desktop Uses
- ssh
- steam
- system: misc system config (i18n etc)
- user: sets up user account and groups
- vscode: enables vscode

- minimal: minimal installs
- homelab: collection of modules for home server
- default: collection of modules for desktop Uses
- mobile: collection of modules for use with mobile-nixos


## Darwin
- aerospace: tiling WM
- brew: homebrew setup
- cli: collection of cli tools
- hm: home-manager setup
- networking
- ssh
- system
- user

- default: enables all these modules

## home
- cli
- cliLinux: extension of cli with linux specific tools
- cosmetic: provides theme and background management
- cursor: changes mouse cursor
- fonts: sets up fonts
- ghostty
- gnome: configures dconf
- plasma: uses plasma-manager to configure KDE
- ssh
- standalone: configures home-manager only install
- vscode
- xournal
- zed

- minPkgs: minimal packages sets
- linuxMinPkgs: minimal packages for linux
- extraPackages: additional packages including second browser etc
- extraLinuxPkgs: adds wider range of linux packages including full office suit
