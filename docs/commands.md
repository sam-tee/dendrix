# Commands

## Format all Nix files:

```sh
nix fmt .
```

## Check all Nix files:

```sh
nix flake check
```

## Build/check a NixOS configuration:

```sh
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

## Build a package:

```sh
nix build .#packages.<system>.<package>
```

Use the system matching the machine you are building on, falling back to
`x86_64-linux` if a package is unavailable for your system.

## Switch a NixOS host:

```sh
sudo nixos-rebuild switch --flake ~/dendrix#<hostname>
```

## Deploy a remote host:

```sh
nhw -H <hostname> -R
```
