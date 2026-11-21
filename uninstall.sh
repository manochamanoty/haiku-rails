#!/usr/bin/env bash
# haiku-rails を外す。settings.json は変えない（入れた設定は自分で消す）。
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  rm -rf "$DEST/skills/$name"
done
rm -rf "$DEST/haiku-rails"

if [ -f "$DEST/CLAUDE.md" ]; then
  tmp="$DEST/CLAUDE.md.tmp"
  grep -v -e '^# haiku-rails（共通ルール）$' -e '^@.*haiku-rails/RULES\.md$' "$DEST/CLAUDE.md" > "$tmp" || true
  mv "$tmp" "$DEST/CLAUDE.md"
fi

echo "haiku-rails を外しました（バックアップ $DEST/haiku-rails-backup/ は残しています）"
