---
name: mr
description: GitLab のマージリクエストを作る。requirements.md・plan.md・review.md と差分から説明文を型どおりに書き、ユーザーのOKをもらってから glab で作成する。「MRを作って」「マージリクエスト」と言われたときに使う。
argument-hint: "[draft（下書きで作るとき）]"
allowed-tools: Read(~/.claude/skills/**) Read(~/.claude/haiku-rails/**)
---

# マージリクエストを作る

## 手順

1. 作業フォルダ（`.rails/` の一番新しいもの）の requirements.md・plan.md・review.md を読む。
   - review.md が無い、または判定が「出してよい」でなければ、先に `/self-review` をすすめて止まる。ユーザーが「そのまま作って」と言えば進める。
2. ベースブランチを調べ（`git symbolic-ref --short refs/remotes/origin/HEAD`）、`git log --oneline <ベース>..HEAD` と `git diff --stat <ベース>...HEAD` を見る。
3. `${CLAUDE_SKILL_DIR}/references/example-mr.md` を読み、**同じ書き方**で作業フォルダに `mr.md` を書く（形は下）。
   - タイトル：「<何をしたか>（<課題キー>）」。課題キーは requirements.md の関連リンクから。無ければ括弧ごと省く。
   - 「確認したこと」には、実際に実行したコマンドと結果だけを書く（plan.md の実装メモ・review.md から）。
4. タイトルと mr.md をユーザーに見せ、「この内容で作ってよいか」を聞いて**止まる**。
5. OKが出たら作る。
   - `git push -u origin <今のブランチ>`
   - `glab mr create --title "<タイトル>" --description "$(cat <mr.md のパス>)" --target-branch <ベースのブランチ名> --remove-source-branch --yes`（引数が draft なら `--draft` を足す）
   - glab が無い・失敗したときは、mr.md の中身と、ブラウザで作るためのURL（push の出力に出る）をユーザーに渡す。
6. できたMRのURLを plan.md の「実装メモ」に書き、ユーザーに伝える。次に `/backlog-note done` と `/explain` をすすめる。

## mr.md の形

```markdown
## 概要
<何を・なぜ。2〜3行>

## 関連
- 課題：<URL>

## 変更点
- `<ファイル>`：<何を変えたか>

## 確認したこと
- `<コマンド>`：<結果（例：42件すべて成功）>

## 影響範囲
<どこに影響するか・しないか>

## レビューしてほしい点
- 

## 補足
<Opus への相談の要点、残した課題、やらなかったこと>
```

## 守ること

- 説明に、実行していない確認や、推測の影響範囲を書かない（分からなければ「未確認」）。
- パスワード・トークン・個人情報を書かない。
- 社内の人が読む文章なので、スキル名（/consult など）や `.rails/` のファイル名は書かない。Opus に相談して決めたことは、決めた内容と理由だけを書く。
