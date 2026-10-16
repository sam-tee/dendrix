#!/usr/bin/env bash
# Bump the pinned T3 Code nightlies (desktop AppImage + CLI tarball) in this
# repo to the latest upstream nightly release, then verify they build.
#
# Usage: update-t3code-nightly.sh [--check] [--repo PATH] [--host HOST] [--switch]
#
#   --check  print current vs latest nightly without changing anything
#   --repo   flake checkout to update (default: "$HOME/dendrix")
#   --host   nixosConfigurations entry to rebuild (default: basename of --repo host? must be given with --switch)
#   --switch run `nixos-rebuild switch` after a successful bump+build
#
# Intended to run on NixOS (GNU sed). Note nix only sees git-tracked files,
# so the package file must be staged with `git add` (it already is).
set -euo pipefail

command -v curl >/dev/null || { echo "error: curl is required" >&2; exit 1; }
command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }
command -v nix >/dev/null || { echo "error: nix is required" >&2; exit 1; }

REPO="${HOME}/dendrix"
HOST=""
CHECK=0
SWITCH=0

while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK=1; shift ;;
    --switch) SWITCH=1; shift ;;
    --repo) REPO="$2"; shift 2 ;;
    --host) HOST="$2"; shift 2 ;;
    -h | --help)
      sed -n '2,10p' "$0"
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

FILE="$REPO/modules/packages/t3code-nightly.nix"
[ -f "$FILE" ] || {
  echo "error: package file not found: $FILE (is --repo correct?)" >&2
  exit 1
}

current="$(sed -n 's/^[[:space:]]*version = "\([^"]*\)";.*/\1/p' "$FILE" | head -n 1)"
[ -n "$current" ] || {
  echo "error: could not parse current version from $FILE" >&2
  exit 1
}

tag="$(curl -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases?per_page=30" | jq -r '[.[] | select(.prerelease) | .tag_name | select(contains("nightly"))] | first // empty')"
[ -n "$tag" ] || {
  echo "error: no nightly release found via GitHub API" >&2
  exit 1
}
latest="${tag#v}"

echo "current: $current"
echo "latest:  $latest"

if [ "$current" = "$latest" ]; then
  echo "already on the latest nightly"
  exit 0
fi

if [ "$CHECK" -eq 1 ]; then
  echo "update available (dry run, no changes made)"
  exit 0
fi

prefetch() {
  local url="$1"
  local what="$2"
  # NOTE: progress goes to stderr. stdout is captured by the caller, so any
  # stdout noise here would end up inside the sed replacement in bump_file
  # (literal newline -> "unterminated 's' command").
  echo "prefetching $url ..." >&2
  local sri
  sri="$(nix store prefetch-file --json "$url" | jq -r '.hash')"
  if [[ ! "$sri" =~ ^sha256-[A-Za-z0-9+/=]+$ ]]; then
    echo "error: prefetch returned an unexpected hash for $what: $sri" >&2
    return 1
  fi
  printf '%s' "$sri"
}

bump_file() {
  local file="$1" ver="$2" dx86="$3" darm="$4" cx86="$5" carm="$6"
  if [[ ! "$ver" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "error: refusing to bump to unexpected version: $ver" >&2
    return 1
  fi
  # Render to a temp file and rename over the original only on success, so a
  # sed failure can never leave a half-updated package file behind.
  local tmp
  tmp="$(mktemp "$(dirname "$file")/.t3code-nightly.XXXXXX")"
  if ! sed -E \
    -e "s|^([[:space:]]*version = \")[^\"]*(\";.*)|\1${ver}\2|" \
    -e "s|^([[:space:]]*desktop_hash_x86_64 = \")[^\"]*(\";.*)|\1${dx86}\2|" \
    -e "s|^([[:space:]]*desktop_hash_aarch64 = \")[^\"]*(\";.*)|\1${darm}\2|" \
    -e "s|^([[:space:]]*cli_hash_x86_64 = \")[^\"]*(\";.*)|\1${cx86}\2|" \
    -e "s|^([[:space:]]*cli_hash_aarch64 = \")[^\"]*(\";.*)|\1${carm}\2|" \
    "$file" >"$tmp"; then
    rm -f "$tmp"
    echo "error: failed to bump $file" >&2
    return 1
  fi
  mv "$tmp" "$file"
  echo "bumped $file to $ver"
}

desktop_x86="$(prefetch "https://github.com/pingdotgg/t3code/releases/download/v${latest}/T3-Code-${latest}-x86_64.AppImage" "desktop x86_64")"
desktop_arm="$(prefetch "https://github.com/pingdotgg/t3code/releases/download/v${latest}/T3-Code-${latest}-arm64.AppImage" "desktop arm64")"
cli_x86="$(prefetch "https://github.com/pingdotgg/t3code/releases/download/v${latest}/t3-${latest}-linux-x64.tar.gz" "CLI x86_64")"
cli_arm="$(prefetch "https://github.com/pingdotgg/t3code/releases/download/v${latest}/t3-${latest}-linux-arm64.tar.gz" "CLI arm64")"

# Snapshot the original file first: if the bump or the verification below
# fails, restore it so the repo keeps building with the previous nightly.
backup="$(mktemp)"
cp "$FILE" "$backup"
rollback() {
  echo "update failed, restoring $FILE to its previous version ..." >&2
  cp "$backup" "$FILE"
  rm -f "$backup"
  exit 1
}

bump_file "$FILE" "$latest" "$desktop_x86" "$desktop_arm" "$cli_x86" "$cli_arm" || rollback

echo "verifying evaluation ..."
nix eval "$REPO#packages.x86_64-linux.t3code-desktop-nightly.outPath" >/dev/null || rollback
nix eval "$REPO#packages.aarch64-linux.t3code-desktop-nightly.outPath" >/dev/null || rollback
nix eval "$REPO#packages.x86_64-linux.t3code-nightly.outPath" >/dev/null || rollback
nix eval "$REPO#packages.aarch64-linux.t3code-nightly.outPath" >/dev/null || rollback
echo "verifying build ..."
nix build --no-link "$REPO#t3code-desktop-nightly" "$REPO#t3code-nightly" || rollback
rm -f "$backup"
echo "build verified"

if [ "$SWITCH" -eq 1 ]; then
  [ -n "$HOST" ] || {
    echo "error: --host is required with --switch" >&2
    exit 1
  }
  command -v nixos-rebuild >/dev/null || {
    echo "error: nixos-rebuild is required for --switch" >&2
    exit 1
  }
  echo "switching $HOST ..."
  nixos-rebuild switch --flake "$REPO#$HOST"
fi
