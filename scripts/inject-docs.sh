#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/inject-docs.sh [--overwrite-docs] TARGET_REPO

Copies this repository's docs/ starter into TARGET_REPO/docs and appends this
repository's project-context.md into TARGET_REPO/project-context.md (or creates it).

Options:
  --overwrite-docs   Replace TARGET_REPO/docs if it already exists
  -h, --help         Show this help
USAGE
}

err() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

overwrite_docs=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --overwrite-docs)
      overwrite_docs=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      err "unknown option: $1"
      ;;
    *)
      break
      ;;
  esac
done

[ "$#" -eq 1 ] || {
  usage >&2
  exit 1
}

target_repo=$1

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source_repo=$(cd "$script_dir/.." && pwd)
source_docs="$source_repo/docs"
source_context="$source_repo/project-context.md"

[ -d "$target_repo" ] || err "target repo does not exist: $target_repo"
target_repo=$(cd "$target_repo" && pwd)
[ -d "$source_docs" ] || err "source docs directory not found: $source_docs"
[ -f "$source_context" ] || err "source project-context.md not found: $source_context"

target_docs="$target_repo/docs"
target_context="$target_repo/project-context.md"

if [ -e "$target_docs" ] && [ "$overwrite_docs" -ne 1 ]; then
  err "target docs already exists: $target_docs (rerun with --overwrite-docs to replace it)"
fi

if [ "$overwrite_docs" -eq 1 ] && [ -e "$target_docs" ]; then
  rm -rf "$target_docs"
fi

mkdir -p "$target_docs"
( cd "$source_docs" && tar --exclude='.DS_Store' -cf - . ) | ( cd "$target_docs" && tar -xf - )

begin_marker="# BEGIN injected-docs-context (bmad-autodoc)"
end_marker="# END injected-docs-context (bmad-autodoc)"

if [ -f "$target_context" ] && grep -Fq "$begin_marker" "$target_context"; then
  printf 'project-context.md already contains injected block, skipping append\n'
else
  if [ -f "$target_context" ] && [ -s "$target_context" ]; then
    printf '\n\n' >> "$target_context"
  fi

  {
    printf '%s\n\n' "$begin_marker"
    cat "$source_context"
    printf '\n%s\n' "$end_marker"
  } >> "$target_context"

  printf 'Merged project context into %s\n' "$target_context"
fi

printf 'Copied docs starter to %s\n' "$target_docs"
