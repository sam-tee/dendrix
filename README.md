# Dendritic nix flake

Uses flake-parts to make every file under modules/ a module

## Services

|   Service   | Machine | Port | Subdomain | Private |
| :---------: | :-----: | :--: | :-------: | :-----: |
|    atuin    |  u410   | 8888 |   atuin   |    n    |
|   bazarr    |  u410   | 6767 |  bazarr   |    y    |
| calibre-web |  u410   | 8083 |   books   |    n    |
|   Immich    |  u410   | 2283 |  photos   |    n    |
|   forgejo   |  s340   | 3000 |    git    |    n    |
| qbittorrent |  u410   | 4095 |   qbit    |    y    |
|    ntfy     |  u410   | 4198 |   ntfy    |    n    |
|  navidrome  |  u410   | 4533 |   music   |    n    |
|    slskd    |  u410   | 5030 |   slskd   |    y    |
|  jellyseer  |  u410   | 5055 |   seerr   |    y    |
|   radarr    |  u410   | 7878 |  radarr   |    y    |
|  Jellyfin   |  u410   | 8096 |   media   |    n    |
| vaultwarden |  s340   | 8222 |   vault   |    n    |
|  syncthing  |  u410   | 8384 |   sync    |    y    |
|   lidarr    |  u410   | 8686 |  lidarr   |    y    |
|   sonarr    |  u410   | 8989 |  sonarr   |    y    |
|   cockpit   |  u410   | 9090 |   dash    |    y    |
| linkwarden  |  u410   | 9183 |   link    |    y    |
|  prowlarr   |  u410   | 9696 | prowlarr  |    y    |
|   mealie    |  u410   | 9876 |  cooking  |    n    |

Modules that bundle other modules are prefixed with \_ to distinguish them

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

- \_minimal: minimal installs
- \_server: collection of modules for home server
- \_default: collection of modules for desktop uses (no DE)
- \_mobile: collection of modules for use with mobile-nixos (no DE)
- \_plasma: installs plasma with HM configuration
- \_gnome: installs gnome with HM configuration

## Darwin

- aerospace: tiling WM
- brew: homebrew setup
- cli: collection of cli tools
- hm: home-manager setup
- networking
- ssh
- system
- user

- \_default: enables all these modules

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

- \_minimal: min install for home-manager system
- \_linuxMinimal: linux minimal install
