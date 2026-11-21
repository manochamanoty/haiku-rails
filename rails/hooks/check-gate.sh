#!/usr/bin/env bash
# haiku-rails：/impl の終わりに、プロジェクトの確認スクリプト（.claude/check.sh）を走らせる（Stop フック）
# .claude/check.sh が無いプロジェクトでは何もしない。
# 失敗したら exit 2 で、終わらせずに直させる。同じセッションで2回止めたら、それ以上は止めない（空回り防止）。

input="$(cat)"

root="${CLAUDE_PROJECT_DIR:-}"
[ -z "$root" ] && root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
check="$root/.claude/check.sh"
[ -f "$check" ] || exit 0

# 計画のタスクが残っている間は走らせない（後のタスク用のテストは、まだ失敗していて正しいため）。
# 最後のタスクにチェックがついたときだけ、全体を確かめる。
plan="$(ls -t "$root"/.rails/*/plan.md 2>/dev/null | head -n 1)"
if [ -n "$plan" ] && grep -Eq '^[[:space:]]*- \[ \] T[0-9]+' "$plan"; then
  exit 0
fi

sid="$(printf '%s' "$input" | tr '\n' ' ' | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
[ -z "$sid" ] && sid="unknown"
counter="${TMPDIR:-/tmp}/haiku-rails-gate-$sid"
count=0
[ -f "$counter" ] && count="$(cat "$counter" 2>/dev/null || echo 0)"

out="$(cd "$root" && bash "$check" 2>&1)"
code=$?

if [ "$code" -eq 0 ]; then
  rm -f "$counter"
  exit 0
fi

if [ "$count" -ge 2 ]; then
  # 2回止めてもだめなら、終わらせる（ユーザーに判断してもらう）
  rm -f "$counter"
  exit 0
fi
echo $((count + 1)) > "$counter"

{
  echo "【haiku-rails】計画のタスクはすべて終わっていますが、確認スクリプト（.claude/check.sh）が失敗しました（終了コード $code）。"
  echo "終える前に直してください。同じ失敗が2回目なら直さずに止まり、plan.md の「実装メモ」に書いて /consult stuck をすすめてください。"
  echo "ユーザーへの返事は日本語で書いてください。"
  echo "---- 出力の最後の40行 ----"
  printf '%s\n' "$out" | tail -n 40
} >&2
exit 2
