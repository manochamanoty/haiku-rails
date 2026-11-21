---
name: rails-setup
description: haiku-rails の設定を確かめる。~/.claude/settings.json に、Haiku 5.5 への固定・effort・自動圧縮・Opus のモデル指定が入っているかを調べ、足りないものを提案し、OKをもらってから書き足す。ユーザーが /rails-setup を打ったときだけ動く。
disable-model-invocation: true
allowed-tools: Read(~/.claude/skills/**) Read(~/.claude/haiku-rails/**) Read(~/.claude/settings.json)
---

# haiku-rails の設定を確かめる

## 手順

1. 次の2つを読む。
   - `~/.claude/settings.json`（無ければ「まだ無い」と伝え、新しく作る前提で進める）
   - `~/.claude/haiku-rails/settings.example.json`（おすすめの設定）
2. 下の項目を1つずつ調べ、「ある／無い／値が違う」の表にしてユーザーに見せる。

   | 項目 | おすすめ |
   |---|---|
   | env.CLAUDE_CODE_USE_BEDROCK | "1"（Bedrock を使うとき） |
   | env.AWS_REGION | 使っているリージョン（例：ap-northeast-1） |
   | env.ANTHROPIC_MODEL | Haiku 5.5 のID |
   | env.ANTHROPIC_DEFAULT_HAIKU_MODEL | Haiku 5.5 のID |
   | env.ANTHROPIC_DEFAULT_SONNET_MODEL | Haiku 5.5 のID（Sonnet を指定したものも Haiku で動かして、予算を守る） |
   | env.CLAUDE_CODE_SUBAGENT_MODEL | Haiku 5.5 のID |
   | env.ANTHROPIC_DEFAULT_OPUS_MODEL | Opus 5.5 のID（/opus-review で使う） |
   | env.CLAUDE_CODE_AUTO_COMPACT_WINDOW | "100000"（10万トークンで圧縮。Haiku 5.5 は10万を超えると単価が上がるため） |
   | modelSettings.<Haiku 5.5 のID>.effortLevel | "high" |
   | statusLine | `bash ~/.claude/haiku-rails/statusline.sh`（任意） |

3. モデルのIDが分からなければ、ユーザーのOKをもらってから `aws bedrock list-inference-profiles --region <リージョン>` を実行し、Haiku 5.5 と Opus 5.5 の候補を見せて**選んでもらう**（勝手に決めない）。
4. 書き足す内容を、差分の形でユーザーに見せ、OKをもらってから書く。
   - 先に元のファイルを `~/.claude/settings.json.bak-<YYYYMMDD-HHMM>` にコピーする。
   - ほかの項目は消さない・並べ替えない。JSON として正しいか、書いた後に確かめる（`python -m json.tool` や `jq .` があれば使う）。
5. 「Claude Code を再起動すると反映されます。再起動後に `/status` で、モデルと effort を確かめてください」と伝える。

## 守ること

- アクセスキーやパスワードを settings.json に書かない。AWS の認証は、今の方法（プロファイルなど）のままにする。
