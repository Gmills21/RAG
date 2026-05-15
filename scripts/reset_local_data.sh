#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Reset Kotaemon local app data.

Usage:
  scripts/reset_local_data.sh [--yes]

Options:
  --yes, -y   Skip confirmation for non-interactive reset.
  --help      Show this help.

This script deletes and recreates only ./ktem_app_data in the repository root.
It does not delete docs, prompts, sample data, env files, or source files.
EOF
}

assume_yes="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --yes|-y)
      assume_yes="true"
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_help >&2
      exit 2
      ;;
  esac
  shift
done

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(CDPATH= cd -- "$script_dir/.." && pwd)"
target="$repo_root/ktem_app_data"

cd "$repo_root"

expected_target="$repo_root/ktem_app_data"
if [ "$target" != "$expected_target" ]; then
  echo "Refusing to reset unexpected path: $target" >&2
  exit 1
fi

echo "Stopping Docker Compose, if it is running..."
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  if ! docker compose down; then
    echo "Warning: docker compose down failed; continuing with local data reset."
  fi
else
  echo "Docker Compose not available; skipping docker compose down."
fi

if [ "$assume_yes" != "true" ]; then
  echo
  echo "This will delete and recreate:"
  echo "  ./ktem_app_data"
  echo
  printf 'Type "reset local data" to continue: '
  read -r confirmation
  if [ "$confirmation" != "reset local data" ]; then
    echo "Aborted. No data was deleted."
    exit 1
  fi
fi

rm -rf -- "$target"
mkdir -p -- "$target"

echo "Reset complete: ./ktem_app_data has been recreated."
echo "Next command: docker compose up -d"
