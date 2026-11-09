#!/usr/bin/env bash
# Fetch Forgejo Actions runs/logs for this repo via the API.
#
#   scripts/ci-logs.sh [list [N]]            list the N most recent runs (default 10)
#   scripts/ci-logs.sh <run|latest|failed>   print the job logs for a run
#
# <run> is the run number shown in the UI (/actions/runs/<run>). Logs are
# printed with ANSI colours and timestamps stripped; pass --raw to keep them.
# Token: $FORGEJO_TOKEN, else the one stored by `fj auth login`.
set -euo pipefail

FORGEJO_URL="${FORGEJO_URL:-https://git.samtee.party}"
REPO="${FORGEJO_REPO:-sam-tee/dendrix}"
API="$FORGEJO_URL/api/v1/repos/$REPO/actions"

raw=0
args=()
for a in "$@"; do
  if [ "$a" = "--raw" ]; then raw=1; else args+=("$a"); fi
done
set -- "${args[@]+"${args[@]}"}"

if [ -z "${FORGEJO_TOKEN:-}" ]; then
  keys="${XDG_DATA_HOME:-$HOME/.local/share}/forgejo-cli/keys.json"
  host="${FORGEJO_URL#*://}"
  FORGEJO_TOKEN="$(jq -r --arg h "$host" '.hosts[$h].token // empty' "$keys" 2>/dev/null || true)"
fi
if [ -z "${FORGEJO_TOKEN:-}" ]; then
  echo "No token: set FORGEJO_TOKEN or run 'fj auth login'" >&2
  exit 1
fi

api() { curl -fsSL -H "Authorization: token $FORGEJO_TOKEN" "$API/$1"; }

runs_page() { api "runs?limit=$1&page=$2"; }

list_runs() {
  runs_page "${1:-10}" 1 | jq -r '.workflow_runs[]
    | "#\(.index_in_repo)\t\(.status)\t\(.trigger_event)\t\(.started // "-")\t\(.title)"' \
    | column -t -s $'\t'
}

# Resolve a run number / keyword to the API run id.
resolve_run() {
  local want="$1" page=1 id
  while :; do
    local json
    json="$(runs_page 50 "$page")"
    [ "$(jq '.workflow_runs | length' <<<"$json")" -gt 0 ] || break
    case "$want" in
      latest) id="$(jq -r '.workflow_runs[0].id' <<<"$json")" ;;
      failed) id="$(jq -r 'first(.workflow_runs[] | select(.status == "failure") | .id) // empty' <<<"$json")" ;;
      *) id="$(jq -r --argjson n "$want" 'first(.workflow_runs[] | select(.index_in_repo == $n) | .id) // empty' <<<"$json")" ;;
    esac
    if [ -n "$id" ]; then echo "$id"; return; fi
    page=$((page + 1))
  done
  echo "Run '$want' not found" >&2
  exit 1
}

show_logs() {
  local run_id job_ids
  run_id="$(resolve_run "$1")"
  job_ids="$(api "runs/$run_id/jobs" | jq -r '.[].id')"
  for job in $job_ids; do
    api "jobs/$job" | jq -r '"=== job \(.name) (\(.status)) \(.html_url)"'
    if [ "$raw" = 1 ]; then
      api "jobs/$job/logs"
    else
      api "jobs/$job/logs" | sed -E 's/^[0-9T:.-]+Z //; s/\x1b\[[0-9;]*[A-Za-z]//g'
    fi
  done
}

case "${1:-list}" in
  list) list_runs "${2:-10}" ;;
  -h | --help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
  *) show_logs "$1" ;;
esac
