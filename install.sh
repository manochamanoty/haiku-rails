#!/usr/bin/env bash
# haiku-rails のインストール（Mac・Linux・Windows の Git Bash）
#   bash install.sh                 … ~/.claude に入れる
#   bash install.sh --keep-skills   … 同じ名前のスキルがすでにあれば上書きしない
# 入れるもの：~/.claude/haiku-rails/（共通ルール・フック・ステータスライン）、~/.claude/skills/<各スキル>、
#             ~/.claude/CLAUDE.md への1行（共通ルールの読み込み）。settings.json は変えない（/rails-setup で確かめる）。
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
KEEP=0
[ "${1:-}" = "--keep-skills" ] && KEEP=1

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/haiku-rails-backup/$STAMP"
backed=0
backup() { # $1: DEST からの相対パス
  if [ -e "$DEST/$1" ]; then
    mkdir -p "$BACKUP/$(dirname "$1")"
    cp -R "$DEST/$1" "$BACKUP/$1"
    backed=1
  fi
}

# フックのパス：ふつうは $HOME を残して、どのPCでも同じに動くようにする
if [ "$DEST" = "$HOME/.claude" ]; then
  RAILS_DIR_IN_HOOK='$HOME/.claude/haiku-rails'
  IMPORT_LINE='@~/.claude/haiku-rails/RULES.md'
else
  RAILS_DIR_IN_HOOK="$DEST/haiku-rails"
  IMPORT_LINE="@$DEST/haiku-rails/RULES.md"
fi

mkdir -p "$DEST/skills"

# 1. 共通ルール・フック・ステータスライン
backup haiku-rails
rm -rf "$DEST/haiku-rails"
mkdir -p "$DEST/haiku-rails"
cp -R "$SRC/rails/." "$DEST/haiku-rails/"
cp "$SRC/settings.example.json" "$DEST/haiku-rails/settings.example.json"
cp "$SRC/templates/check.sh.example" "$DEST/haiku-rails/check.sh.example"
chmod +x "$DEST/haiku-rails/hooks/"*.sh "$DEST/haiku-rails/statusline.sh" 2>/dev/null || true

# 2. スキル
installed=""
skipped=""
for d in "$SRC"/skills/*/; do
  name="$(basename "$d")"
  if [ "$KEEP" = 1 ] && [ -e "$DEST/skills/$name" ]; then
    skipped="$skipped $name"
    continue
  fi
  backup "skills/$name"
  rm -rf "$DEST/skills/$name"
  cp -R "$d" "$DEST/skills/$name"
  # フックのパスを埋める
  if grep -q "__RAILS_DIR__" "$DEST/skills/$name/SKILL.md" 2>/dev/null; then
    tmp="$DEST/skills/$name/SKILL.md.tmp"
    sed "s#__RAILS_DIR__#${RAILS_DIR_IN_HOOK}#g" "$DEST/skills/$name/SKILL.md" > "$tmp"
    mv "$tmp" "$DEST/skills/$name/SKILL.md"
  fi
  installed="$installed $name"
done

# 3. CLAUDE.md に、共通ルールを読み込む1行を足す（すでにあれば何もしない）
backup CLAUDE.md
touch "$DEST/CLAUDE.md"
if ! grep -qxF "$IMPORT_LINE" "$DEST/CLAUDE.md"; then
  printf '\n# haiku-rails（共通ルール）\n%s\n' "$IMPORT_LINE" >> "$DEST/CLAUDE.md"
fi

echo "haiku-rails を入れました：$DEST"
echo "  スキル：${installed:- なし}"
if [ -n "$skipped" ]; then echo "  そのままにしたスキル（--keep-skills）：$skipped"; fi
if [ "$backed" = 1 ]; then echo "  上書き前のものは $BACKUP にあります"; fi
echo
echo "次にやること："
echo "  1. Claude Code を起動し直す"
echo "  2. /rails-setup を打って、モデル（Haiku 5.5 / Opus 5.5）と effort の設定を確かめる"
