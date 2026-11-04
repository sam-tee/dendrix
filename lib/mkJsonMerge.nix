{lib, ...}: let
  inherit (lib) assertOneOf escapeShellArgs getExe;
  mergeScript = pkgs:
    pkgs.writeShellApplication {
      name = "json-merge";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.diffutils
        pkgs.jq
        (pkgs.python3Packages.toPythonApplication pkgs.python3Packages.json5)
      ];
      text = ''
        set -uo pipefail
        target=$1 nix=$2 mode=$3 operation=$4 file_mode=$5

        warn() {
          echo "json-merge: $target: warning: $*" >&2
          exit 0
        }

        dest=$target store_link=
        if [[ -L $target ]]; then
          resolved=$(readlink -f -- "$target") || warn "cannot resolve symlink, using old settings"
          if [[ $resolved == /nix/store/* ]]; then store_link=1; else dest=$resolved; fi
        fi
        mkdir -p -- "$(dirname -- "$dest")" || warn "cannot create parent directory, using old settings"

        work=$(mktemp -d) || warn "cannot create temp dir, using old settings"
        result=
        trap 'rm -rf -- "$work"; [[ -z $result ]] || rm -f -- "$result"' EXIT

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
          jq . "$work/current" > "$result" || warn "cannot copy existing file, using old settings"
        else
          jq -n --slurpfile current "$work/current" --slurpfile nix "$nix" \
            "\$current[0] as \$current | \$nix[0] as \$nix | (
              $operation
            )" > "$result" || warn "merge failed, leaving file untouched"
          if [[ -z $store_link ]] && cmp -s <(jq -S . "$work/current") <(jq -S . "$result"); then
            exit 0
          fi
        fi

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
  mkJsonMerge = pkgs: {
    path,
    settings,
    mode ? "merge",
    operation ? "$current * $nix",
    fileMode ? "600",
    name ? "json-merge-settings",
  }:
    assert assertOneOf "mkJsonMerge mode" mode ["merge" "seed"];
      escapeShellArgs [
        (getExe (mergeScript pkgs))
        path
        ((pkgs.formats.json {}).generate "${name}.json" settings)
        mode
        operation
        fileMode
      ];
}
