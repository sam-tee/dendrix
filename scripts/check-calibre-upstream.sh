#!/usr/bin/env bash
# Watches nixpkgs-unstable for changes that may make the local
# calibre/piper-tts workarounds removable.
#
# Workarounds:
#   modules/gui/calibre.nix         (piper-tts withTrain=false)
#   modules/homelab/calibre-web.nix (calibre speechSupport=false)
# Added because vanilla piper-tts 1.8.0 (incl. torch/librosa train
# closure) fails to build on aarch64-linux, which breaks calibre 9.16.0
# and therefore the oracle host.
#
# What this checks (cheap: curl only, no builds):
#   1. Upstream versions of piper-tts/calibre vs the versions the
#      workaround was validated against (KNOWN_BROKEN_* below).
#      A bump means there is something new worth re-testing.
#   2. That our override knobs (withTrain, speechSupport) still exist
#      upstream. If one disappears, the override breaks at the next
#      `nix flake update` -> act immediately.
#
# After re-testing a vanilla build on aarch64-linux:
#   - still broken -> bump KNOWN_BROKEN_* to the tested versions.
#   - fixed      -> delete the overrides and this watcher.
#
# Limitation: a same-version upstream fix (e.g. librosa rebuild) does
# not change versions and is NOT detected. For that, manually run a
# vanilla `nix build` of piper-tts/calibre for aarch64-linux.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_BRANCH="nixpkgs-unstable"

KNOWN_BROKEN_PIPER_TTS="1.8.0"
KNOWN_BROKEN_CALIBRE="9.16.0"

PIPER_PATH="pkgs/by-name/pi/piper-tts/package.nix"
CALIBRE_PATH="pkgs/by-name/ca/calibre/package.nix"

fetch_file() {
  curl -sSL --fail --max-time 60 \
    "https://raw.githubusercontent.com/NixOS/nixpkgs/$1/$2"
}

extract_version() {
  grep -m1 '^  version = "' | sed 's/.*"\(.*\)".*/\1/'
}

upstream_piper="$(fetch_file "$UPSTREAM_BRANCH" "$PIPER_PATH" | extract_version)"
upstream_calibre="$(fetch_file "$UPSTREAM_BRANCH" "$CALIBRE_PATH" | extract_version)"
upstream_piper_file="$(fetch_file "$UPSTREAM_BRANCH" "$PIPER_PATH")"
upstream_calibre_file="$(fetch_file "$UPSTREAM_BRANCH" "$CALIBRE_PATH")"

moved=false
knob_gone=false
reasons=()

if [ "$upstream_piper" != "$KNOWN_BROKEN_PIPER_TTS" ]; then
  moved=true
  reasons+=("piper-tts moved upstream: $KNOWN_BROKEN_PIPER_TTS -> $upstream_piper")
fi
if [ "$upstream_calibre" != "$KNOWN_BROKEN_CALIBRE" ]; then
  moved=true
  reasons+=("calibre moved upstream: $KNOWN_BROKEN_CALIBRE -> $upstream_calibre")
fi
if ! grep -q "withTrain ?" <<<"$upstream_piper_file"; then
  knob_gone=true
  reasons+=("URGENT: 'withTrain' knob gone from upstream piper-tts (override in modules/gui/calibre.nix will break on next flake update)")
fi
if ! grep -q "speechSupport" <<<"$upstream_calibre_file"; then
  knob_gone=true
  reasons+=("URGENT: 'speechSupport' knob gone from upstream calibre (override in modules/homelab/calibre-web.nix will break on next flake update)")
fi

if [ "$moved" = true ] || [ "$knob_gone" = true ]; then
  echo "CALIBRE-WATCH: action needed"
  printf '  - %s\n' "${reasons[@]}"
  echo "Re-test a vanilla aarch64-linux build (temporarily revert the overrides), then update KNOWN_BROKEN_* or remove the workaround."
else
  echo "CALIBRE-WATCH: OK (upstream piper-tts=$upstream_piper calibre=$upstream_calibre, knobs intact)"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    echo "moved=$moved"
    echo "knob_gone=$knob_gone"
    echo "upstream_piper=$upstream_piper"
    echo "upstream_calibre=$upstream_calibre"
  } >>"$GITHUB_OUTPUT"
fi
