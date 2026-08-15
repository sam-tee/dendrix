#!/usr/bin/env bash
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
services="$repo/modules/homelab/hlServices.nix"
readme="$repo/README.md"

awk '
  BEGIN {
    split("Service|Machine|Port|Subdomain|Private", header, "|")
    for (i = 1; i <= 5; i++) width[i] = length(header[i])
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
  NR == FNR {
    if ($0 ~ / = mkService /) {
      name = $1
      port = $4
      host = $5
      priv = $6
      subdomain = $7
      gsub(/"/, "", host)
      gsub(/"/, "", subdomain)
      gsub(/;/, "", subdomain)
      if (host == "") host = "-"
      if (port == "0") port = "-"
      if (subdomain == "") subdomain = "-"
      if (priv == "true") priv = "y"; else priv = "n"
      count++
      cell[count,1] = name
      cell[count,2] = host
      cell[count,3] = port
      cell[count,4] = subdomain
      cell[count,5] = priv
      for (i = 1; i <= 5; i++) if (length(cell[count,i]) > width[i]) width[i] = length(cell[count,i])
    }
    next
  }
  /<!-- services-table:start -->/ {
    print
    for (i = 1; i <= 5; i++) width[i] += 2
    printf "|"
    for (i = 1; i <= 5; i++) printf " %s |", center(header[i], width[i])
    printf "\n|"
    for (i = 1; i <= 5; i++) printf " %s |", center(":" dashes(width[i]-2) ":", width[i])
    printf "\n"
    for (r = 1; r <= count; r++) {
      printf "|"
      for (i = 1; i <= 5; i++) printf " %s |", center(cell[r,i], width[i])
      printf "\n"
    }
    inside = 1
    next
  }
  /<!-- services-table:end -->/ { print; inside = 0; next }
  !inside { print }
' "$services" "$readme" > "$readme.tmp"
mv "$readme.tmp" "$readme"

if git -C "$repo" diff --quiet -- README.md; then
  echo "README is up to date"
else
  echo "README services table updated"
fi