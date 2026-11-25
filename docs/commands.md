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

Hosts with `autoDeploy` (default: servers) run [comin](https://github.com/nlewo/comin)
(`modules/system/comin.nix`) and deploy themselves from the `deploy` branch,
which CI force-pushes to the built `main` commit after a successful build
and cache push (comin ignores it if it ever moves backwards).
Results are posted to the `deploy` ntfy topic. Set
`hosts.<name>.autoDeploy = false` to opt a server out.

To trial a commit on one server without a boot entry, push it on top of
`deploy` to `testing-<hostname>`:

```sh
git push origin HEAD:testing-<hostname>
```

Manual `nhw` deploys to these hosts are replaced by the next commit comin
deploys.

## CI runs and logs (Forgejo Actions):

CI is `.forgejo/workflows/cache.yml` on `git.samtee.party` (not GitHub, so
`gh` does not work). Uses `$FORGEJO_TOKEN` or the `fj auth login` token.

```sh
scripts/ci-logs.sh list [N]               # recent runs with status
scripts/ci-logs.sh <run|latest|failed>    # job logs (ANSI/timestamps stripped, --raw to keep)
```
