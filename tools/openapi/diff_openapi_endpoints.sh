#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  tools/openapi/diff_openapi_endpoints.sh <old_openapi.json> <new_openapi.json>

Example:
  tools/openapi/diff_openapi_endpoints.sh openapi-prev.json openapi.json
EOF
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

OLD_SPEC="$1"
NEW_SPEC="$2"

if [[ ! -f "$OLD_SPEC" || ! -f "$NEW_SPEC" ]]; then
  echo "Error: both spec files must exist." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: required command not found: jq" >&2
  exit 1
fi

extract() {
  jq -r '
    .paths as $paths
    | $paths
    | to_entries[]
    | .key as $path
    | .value
    | to_entries[]
    | select(.key|test("^(get|post|put|patch|delete)$"))
    | "\(.key|ascii_upcase) \($path) \(.value.operationId // "-")"
  ' "$1" | sort
}

old_tmp="$(mktemp)"
new_tmp="$(mktemp)"
trap 'rm -f "$old_tmp" "$new_tmp"' EXIT

extract "$OLD_SPEC" > "$old_tmp"
extract "$NEW_SPEC" > "$new_tmp"

echo "== Added endpoints =="
comm -13 "$old_tmp" "$new_tmp" || true
echo
echo "== Removed endpoints =="
comm -23 "$old_tmp" "$new_tmp" || true
