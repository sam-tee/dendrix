# Merge Nix-declared JSON into a file an app also writes to, leaving it writable.
# Returns a shell command; run it as the file's owner, e.g. via `mutableJson`.
{lib, ...}: let
  mergeScript = pkgs:
    pkgs.writeShellApplication {
      name = "json-merge";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.diffutils
        pkgs.jq
        # Reads JSONC/JSON5 (comments, trailing commas) as written by e.g. Zed
        (pkgs.python3Packages.toPythonApplication pkgs.python3Packages.json5)
      ];
      text = ''
        set -uo pipefail
        target=$1 nix=$2 mode=$3 operation=$4 file_mode=$5

        # Never fail activation: warn and keep the existing file instead.
        warn() {
          echo "json-merge: $target: warning: $*" >&2
          exit 0
        }

        # Write through symlinks, except read-only ones into the Nix store
        # (e.g. a previously hjem-managed file), which are replaced by a copy
        dest=$target store_link=
        if [[ -L $target ]]; then
          resolved=$(readlink -f -- "$target") || warn "cannot resolve symlink, using old settings"
          if [[ $resolved == /nix/store/* ]]; then store_link=1; else dest=$resolved; fi
        fi
        mkdir -p -- "$(dirname -- "$dest")" || warn "cannot create parent directory, using old settings"

        work=$(mktemp -d) || warn "cannot create temp dir, using old settings"
        result=
        trap 'rm -rf -- "$work"; [[ -z $result ]] || rm -f -- "$result"' EXIT

        # Snapshot the current contents so a concurrent app write is detected
        existed=
        if [[ -s $target ]]; then
          existed=1
          if [[ $mode == seed && -z $store_link ]]; then
            exit 0
          fi
          cat -- "$target" > "$work/snapshot" || warn "cannot read existing file, using old settings"
          pyjson5 --as-json "$work/snapshot" > "$work/current" 2> "$work/error" \
            || warn "cannot parse existing file, leaving it untouched ($(tail -n 1 "$work/error"))"
        fi

        result=$(mktemp "$dest.XXXXXX") || warn "cannot create temp file, using old settings"
        if [[ -z $existed ]]; then
          jq . "$nix" > "$result" || warn "cannot render declared settings, using old settings"
        elif [[ $mode == seed ]]; then
          # Store symlink in seed mode: materialise its contents normalized to plain JSON
          jq . "$work/current" > "$result" || warn "cannot copy existing file, using old settings"
        else
          jq -n --slurpfile current "$work/current" --slurpfile nix "$nix" \
            "\$current[0] as \$current | \$nix[0] as \$nix | (
              $operation
            )" > "$result" || warn "merge failed, leaving file untouched"
          # Nothing to change: keep the file (and any comments in it) as-is
          if [[ -z $store_link ]] && cmp -s <(jq -S . "$work/current") <(jq -S . "$result"); then
            exit 0
          fi
        fi

        # Bail if the app wrote the file while we were merging
        if [[ -n $existed ]]; then
          cmp -s -- "$work/snapshot" "$target" || warn "changed during activation, keeping the newer file"
        elif [[ -s $target ]]; then
          warn "created during activation, keeping the newer file"
        fi

        if [[ -z $store_link && -f $dest ]]; then
          chmod --reference="$dest" -- "$result" || warn "cannot preserve permissions, using old settings"
        else
          chmod "$file_mode" -- "$result" || warn "cannot set permissions, using old settings"
        fi
        mv -f -- "$result" "$dest" || warn "cannot install merged file, using old settings"
        result=
      '';
    };
in {
  flake.lib.mkJsonMerge = pkgs: {
    # Runtime path of the JSON file
    path,
    # Nix value to merge in
    settings,
    # "merge": apply `operation` on every activation; "seed": only write a
    # missing/empty file, so later Nix changes don't reach existing files
    mode ? "merge",
    # jq expression over `$current` (file contents) and `$nix` (declared
    # value). The default deep-merges objects with Nix winning; arrays and
    # scalars are replaced, and keys later removed from Nix stay in the file.
    operation ? "$current * $nix",
    # Permissions for newly created files; existing files keep theirs
    fileMode ? "600",
    name ? "json-merge-settings",
  }:
    assert lib.assertOneOf "mkJsonMerge mode" mode ["merge" "seed"];
      lib.escapeShellArgs [
        (lib.getExe (mergeScript pkgs))
        path
        ((pkgs.formats.json {}).generate "${name}.json" settings)
        mode
        operation
        fileMode
      ];
}
