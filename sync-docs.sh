#!/usr/bin/env bash
set -euo pipefail

# Syncs aws-sso-cli documentation from upstream into src/.
# Shallow-clones the repo, copies all Markdown files preserving structure.

REPO_URL="https://github.com/synfinatic/aws-sso-cli.git"
DOCS_SUBDIR="docs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPDIR_PREFIX="aws-sso-cli-docs-sync"

TARGET_DIR="$SCRIPT_DIR/src"

cleanup() {
  if [[ -n "${tmp_dir:-}" && -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi
}
trap cleanup EXIT

tmp_dir="$(mktemp -d -t "${TMPDIR_PREFIX}.XXXXXX")"

echo "Cloning aws-sso-cli (shallow)..."
git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$tmp_dir/aws-sso-cli"

cd "$tmp_dir/aws-sso-cli"
git sparse-checkout set "$DOCS_SUBDIR"

echo "Removing old docs from target..."
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

echo "Copying Markdown files..."
src="$tmp_dir/aws-sso-cli/$DOCS_SUBDIR"
find "$src" -name "*.md" -type f | while read -r file; do
  rel="${file#"$src"/}"
  dest="$TARGET_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$file" "$dest"
done

count="$(find "$TARGET_DIR" -name "*.md" -type f | wc -l | tr -d ' ')"
echo "Done. $count Markdown files synced into src/."
