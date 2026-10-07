#!/usr/bin/env bash
set -euo pipefail

command -v nix >/dev/null || { echo "error: nix is required by scripts/update-hosts-docs.sh" >&2; exit 1; }

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$repo/docs"
doc="$repo/docs/hosts.md"
rows="$(mktemp)"
table="$(mktemp)"
trap 'rm -f "$rows" "$table"' EXIT

# Rows come from evaluated flake data, so any formatting of
# modules/hosts/*.nix works. Note nix only sees git-tracked files, so
# stage new files with `git add` before running this.
nix eval --raw "$repo#hosts" --apply '
  hs: builtins.concatStringsSep "\n" (builtins.concatMap (n: let
    h = hs.${n};
  in
    if h.system == "" then [] else [
      "`${n}`|`${h.system}`|${if h.hostType == "" then "-" else h.hostType}|${if h.modules == [] then "-" else builtins.concatStringsSep ", " h.modules}"
    ]) (builtins.sort builtins.lessThan (builtins.attrNames hs)))
' > "$rows"

# Render the centered markdown table.
awk -F'|' -v hdr="Host|System|Type|Modules" '
  BEGIN {
    n = split(hdr, header, "|")
    for (i = 1; i <= n; i++) width[i] = length(header[i])
  }
  function center(s, w,   left, right) {
    left = int((w - length(s)) / 2)
    right = w - length(s) - left
    return sprintf("%*s%s%*s", left, "", s, right, "")
  }
  function dashes(n,   s) {
    s = ""
    while (n-- > 0) s = s "-"
    return s
  }
  {
    count++
    for (i = 1; i <= n; i++) {
      cell[count,i] = $i
      if (length($i) > width[i]) width[i] = length($i)
    }
  }
  END {
    for (i = 1; i <= n; i++) width[i] += 2
    printf "|"
    for (i = 1; i <= n; i++) printf " %s |", center(header[i], width[i])
    printf "\n|"
    for (i = 1; i <= n; i++) printf " %s |", center(":" dashes(width[i]-2) ":", width[i])
    printf "\n"
    for (r = 1; r <= count; r++) {
      printf "|"
      for (i = 1; i <= n; i++) printf " %s |", center(cell[r,i], width[i])
      printf "\n"
    }
  }
' "$rows" > "$table"

# Canonical copy under docs/; README.md and AGENTS.md link here.
{
  printf '# Hosts\n\nAuto-generated mirror — do not edit by hand. Source of truth: `flake.hosts` in `modules/hosts/*.nix` (via `scripts/update-hosts-docs.sh`).\n\n'
  cat "$table"
} > "$doc"

if git -C "$repo" diff --quiet -- docs/; then
  echo "Hosts docs are up to date"
else
  echo "Hosts docs updated"
fi
