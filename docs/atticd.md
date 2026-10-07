# Attic Cache Setup

On every push (and on a schedule), the `cache` workflow builds all Linux
packages (`flake .#packages` for `x86_64-linux` and `aarch64-linux`) with
`nix-fast-build` and pushes them to the `dendrix` Attic cache. All clients
already use `https://cache.samtee.party/dendrix` as a substituter
(see `modules/nix.nix`).

To set up the cache server from scratch, add the SOPS secret `atticd-env`
containing:

```sh
ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<openssl genrsa -traditional 4096 | base64 -w0>
```

After deploying the host running the Attic server, you need to create and store
a Forgejo token to run the workflow:

```sh
sudo atticd-atticadm make-token --sub forgejo-cache --validity 1y --pull dendrix --push dendrix --create-cache dendrix --configure-cache dendrix --configure-cache-retention dendrix
```

To use the cache before switching, you must first make a token:

```sh
sudo atticd-atticadm make-token --sub sam --validity 1y --pull dendrix
```

Then log in and use the cache:

```sh
attic login --set-default dendrix https://cache.samtee.party "$TOKEN"
attic use dendrix
```

Cache entries are garbage-collected after `3 days`
(`garbage-collection.default-retention-period` in `modules/homelab/atticd.nix`).
