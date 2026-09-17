#!/usr/bin/env bash
set -euo pipefail


ROOT="${1:-.}"

KEEP=(address key public-key)

DRY_RUN=0
[[ "${2:-}" == "--dry-run" || "${1:-}" == "--dry-run" ]] && DRY_RUN=1

rm_it() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "  [dry-run] rm -rf $1"
  else
    rm -rf -- "$1"
    echo "  удалено: $1"
  fi
}

keep_this() {
  local name="$1"
  for k in "${KEEP[@]}"; do
    [[ "$name" == "$k" ]] && return 0
  done
  return 1
}

shopt -s nullglob
found=0

for node in "$ROOT"/node*/; do
  [[ -d "$node" ]] || continue
  found=1
  node="${node%/}"
  echo "==> $node"

  for f in "$node"/besu.log "$node"/besu.pid "$node"/*.log; do
    [[ -e "$f" ]] && rm_it "$f"
  done

  data="$node/data"
  if [[ ! -d "$data" ]]; then
    
    continue
  fi

  for item in "$data"/* "$data"/.[!.]*; do
    [[ -e "$item" ]] || continue
    base="$(basename "$item")"
    if keep_this "$base"; then
      
    else
      rm_it "$item"
    fi
  done
done

