---
name: backlog-note
description: 課題管理（Backlog など）に書くコメントを作る。やったこと・次にやること・リンクを型どおりにまとめ、ユーザーのOKをもらってから投稿する（投稿できるツールがあるとき）。「バックログに書いて」「課題に記録して」と言われたときに使う。
argument-hint: "[start|progress|done]"
allowed-tools: Read(~/.claude/skills/**) Read(~/.claude/haiku-rails/**)
---

# 課題にコメントを書く

種類：$ARGUMENTS（start＝着手 / progress＝途中 / done＝完了。空なら状況から選んで伝える）

## 手順

1. 作業フォルダ（`.rails/` の一番新しいもの）の requirements.md・plan.md と、あれば review.md・MRのURL（plan.md の実装メモ）を読む。
2. `${CLAUDE_SKILL_DIR}/references/example.md` を読み、**同じ書き方**で作業フォルダに `backlog-<種類>.md` を書く（形は下）。
   - 書式は、そのプロジェクトのもの（Markdown か Backlog 記法）に合わせる。分からなければ Markdown。
3. ユーザーに見せて、「この内容で投稿してよいか」を聞いて止まる。
4. OKが出たら：
   - 投稿できるツール（Backlog の MCP など）があれば、該当の課題（requirements.md の関連リンクの課題キー）にコメントとして投稿する。
   - 無ければ、そのまま貼れる形で渡す。
5. 投稿したら、plan.md の「実装メモ」に「課題にコメント（<種類>）」と書く。

## 形

```markdown
### やったこと
- 

### 次にやること
- 

### リンク
- MR：
- 解説ページ・資料：

### 確認したいこと
- （あれば。誰に何を確かめたいか）
```

## 守ること

- やっていないことを「やったこと」に書かない。plan.md のチェックと実装メモにあるものだけ書く。
- 社内の人が読む文章なので、スキル名（/consult など）や `.rails/` のファイル名は書かない。
