#!/usr/bin/env bash
# haiku-rails：ステータスライン。モデル名・いまの文脈の量・費用（定価での目安）を出す。
# Haiku 5.5 は1回の入力が10万トークンを超えると単価が上がるので、8万で注意を出す。

input="$(cat)"

get() { # $1: jq のパス  $2: 見つからないときに探すキー名
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null
    return
  fi
  printf '%s' "$input" | tr '\n' ' ' | sed "s/.*\"${3:-__none__}\"//" \
    | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([^\",}]*\)\"\{0,1\}.*/\1/p" | head -n 1
}

model="$(get '.model.display_name' display_name)"
pct="$(get '.context_window.used_percentage' used_percentage context_window)"
size="$(get '.context_window.context_window_size' context_window_size context_window)"
cost="$(get '.cost.total_cost_usd' total_cost_usd)"

out="${model:-?}"
if [ -n "$pct" ] && [ -n "$size" ] && [ "$pct" != "null" ]; then
  tokens="$(awk -v p="$pct" -v s="$size" 'BEGIN { printf "%d", p * s / 100 }')"
  mark=""
  case "$model" in
    *aiku*)
      if [ "$tokens" -ge 100000 ]; then mark=" ⚠10万超え（単価が上がる）→ /clear か /compact"
      elif [ "$tokens" -ge 80000 ]; then mark=" ⚠もうすぐ10万"
      fi ;;
  esac
  out="$out | 文脈 $((tokens / 1000))k$mark"
fi
if [ -n "$cost" ]; then
  out="$out | \$$(awk -v c="$cost" 'BEGIN { printf "%.2f", c }')"
fi
printf '%s\n' "$out"
