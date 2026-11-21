#!/usr/bin/env bash
# haiku-rails：/impl の間、テストのファイルを書き換えさせない（PreToolUse フック）
# 入力：標準入力に JSON（tool_input.file_path など）。テストのファイルなら exit 2 で止める。

input="$(cat)"

path=""
if command -v jq >/dev/null 2>&1; then
  path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)"
fi
if [ -z "$path" ]; then
  path="$(printf '%s' "$input" | tr '\n' ' ' | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
fi
if [ -z "$path" ]; then
  path="$(printf '%s' "$input" | tr '\n' ' ' | sed -n 's/.*"notebook_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
fi
[ -z "$path" ] && exit 0

# Windows の区切り（\ や \\）を / にそろえ、小文字で比べる
p="$(printf '%s' "$path" | sed 's#\\\\#/#g; s#\\#/#g' | tr '[:upper:]' '[:lower:]')"
name="${p##*/}"
hit=0

case "/$p" in
  */test/*|*/tests/*|*/__tests__/*|*/spec/*|*/specs/*|*/src/test/*) hit=1 ;;
esac
case "$name" in
  test_*|*_test.*|*.test.*|*.spec.*|*_spec.*|*test.java|*tests.java|*test.kt|*tests.cs|*test.cs|*test.php|*test.go) hit=1 ;;
esac

if [ "$hit" = 1 ]; then
  cat >&2 <<EOF
実装の段階（/impl）なので、テストのファイルは変更できません：$path
テストが仕様と合わないと思うなら、作業を止めて、どのテストのどこが requirements.md と合わないかをユーザーに報告してください。
テストを直すのは、ユーザーがOKしてから、/clear して /write-tests で行います。Bash などで回り道をして書き換えないでください。
EOF
  exit 2
fi
exit 0
