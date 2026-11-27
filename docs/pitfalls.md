# Pitfalls

Gotchas that apply across the repo. Problems specific to one file are
explained in a comment next to the code instead.

## Nix

- **Flakes only see git-tracked files.** `git add` new files before
  `nix eval`, `nix build`, `nix flake check` or the `scripts/update-*.sh`
  docs generators, or they will be missing.
- **Don't branch on `pkgs.stdenv.hostPlatform` in generic modules.** Inside
  `flake.modules.generic`, using it to choose between NixOS and darwin
  option sets causes infinite recursion, because `pkgs` itself depends on
  `config`. Use `inherit (lib.platformFromOptions options) isDarwin isLinux;`,
  which checks which option set the module is evaluated in (`systemd` or
  `launchd`).

## NixOS

- **Files written by activation scripts don't restart services.**
  `switch` only restarts units whose unit file changed, so a service that
  reads such a file needs a hash of its inputs in `restartTriggers`.
  Activation runs after units are stopped and before they are restarted, so
  the restarted service sees the new file.
- **`after = ["tailscaled.service"]` doesn't guarantee the tailscale IP
  exists.** tailscaled counts as started before it assigns the address, so
  a service that binds `homelab.machineIP` can fail at boot and use up its
  restart limit. Set `systemd.services.<unit>.waitForTailscaleIP = true`
  on any service that binds `machineIP` (or `mkTsIp` of its own host). It
  orders the unit after `tailscale-ip.service`, which waits until the
  address is on the tailscale interface. Services that only connect to a
  tailscale IP don't need it. Don't set `net.ipv4.ip_nonlocal_bind = 1`
  instead: it applies to every process, lets a wrong IP fail silently, and
  breaks software that checks whether an address is local by trying to
  bind it.
- **sops-nix installs secrets in the `setupSecrets` activation script**
  (unless `sops.useSystemdActivation` is set). An activation script that
  reads a secret must add `"setupSecrets"` to its `deps`, guarded with
  `config.system.activationScripts ? setupSecrets` because the script only
  exists when the host has secrets.

## nix-darwin

- **Custom activation script names never run.** nix-darwin runs a fixed list
  of activation scripts and silently ignores any other
  `system.activationScripts.<name>`. Put your own code in `preActivation`,
  `extraActivation` or `postActivation`, and set its position with `mkOrder`.
- **sops-nix installs secrets with `postActivation.text = mkAfter …`**
  (order 1500). Anything that reads a secret during activation needs
  `mkOrder` above 1500.
- **Activation runs as root with an empty environment (`env -i`).** User
  variables like `XDG_CONFIG_HOME` are unset, so tools run during activation
  fall back to `$HOME` paths (e.g. brew uses `~/.homebrew`). Configure them
  through a system-wide file such as `/etc/homebrew/brew.env`.
- **GUI apps don't see `environment.variables`.** That only reaches shells.
  `launchd.user.envVariables` only runs `launchctl setenv` during activation,
  so the values are gone after a reboot. Use a `launchd.user.agents` entry
  with `RunAtLoad` that runs `launchctl setenv` instead.
- **`system.defaults.CustomUserPreferences` replaces whole dicts.** Each
  top-level key is written with one `defaults write`, so setting one entry of
  a nested dict (e.g. `com.apple.symbolichotkeys` `AppleSymbolicHotKeys`)
  wipes the rest. Merge entries with `defaults write … -dict-add` in
  `postActivation` instead.
