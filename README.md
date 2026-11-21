# haiku-rails

Claude Code を **Claude Haiku 5.5 中心**で使い、Opus 5.5 は「ここぞ」の1回だけ使うための、スキルとルールのセットです。

モデルの賢さで察してもらうのではなく、**レール**（手順・出力の型・良い例・機械のチェック）を敷いて品質を出します。

- **常に読むルールは短く**：`RULES.md`（約30行）だけが、毎回すべての会話に読み込まれます。
- **スキルは段階ごと**：要件・計画・テスト・実装・レビュー・MR・記録・解説。中身は使うときだけ読み込まれます。
- **機械で止める**：実装の途中はテストを書き換えられません。最後のタスクでテストが通らないと、作業を終われません。
- **Opus は人が呼んだときだけ**：`/opus-review` を打ったときに1回だけ動き、読めるのは相談用のファイル1つだけです。

## ふだんの流れ

| # | 段階 | 打つもの | モデル・effort | できるもの（`.rails/<日付>-<名前>/`） |
|---|---|---|---|---|
| 1 | 要件 | `/req <課題の本文やURL>` | Haiku・high | requirements.md（分からない点は質問して止まる） |
| 2 | 相談の準備 | `/consult plan` | Haiku・high | consult-plan-01.md（Opus に渡す材料） |
| 3 | Opus に相談 | `/opus-review <パス>` | **Opus・high・1回** | 進め方とテストケース表（境界値中心） |
| 4 | 計画 | `/task-plan`（3 と同じ会話で） | Haiku・xhigh | plan.md（1タスクずつ、お手本と確認コマンドつき） |
| 5 | テスト | `/write-tests` | Haiku・high | テスト（全部失敗することを確認） |
| 6 | 実装 | `/impl`（タスクごとに `/clear` → `/impl`） | Haiku・high | コードとコミット |
| 7 | レビュー | `/self-review` | Haiku・xhigh（会話を引き継がない） | review.md |
| 8 | MR | `/mr` | Haiku・high | mr.md → `glab mr create` |
| 9 | 課題に記録 | `/backlog-note done` | Haiku・high | 課題へのコメント |
| 10 | 自分用の解説 | `/explain` | Haiku・high | explain.html（ブロックごとの図・用語集つき） |

- 小さな修正なら 1 → 4 → 5 → 6 だけで構いません。
- Opus を使う場面は4つです。タスクが決まったとき（`plan`）、設計の分かれ道（`design`）、同じエラーで2回詰まったとき（`stuck`）、危ない変更を含む MR の前（`risk`）。
- `.rails/` は git に入りません（中に `.gitignore` を置きます）。`/clear` しても、ここから続きを再開できます。

## 試した結果（2026-11-21）

小さな機能（購入ポイントの計算。タスク2つ、テスト24件）を、`/req` から `/explain` まで通しで動かしました。

- **Haiku 5.5**：全段階の合計が約0.25ドル。次のことを確かめました。
  - 要件のあいまいな点を質問して止まった。
  - 実装する前から通ってしまうテストに自分で気づいて報告した。
  - 実装中にテストを直すよう頼むと、フックで止まり、回り道をせずに報告した。
- **Opus 5.5**：`/opus-review` を1回（effort high）使って0.30ドル。読んだのは相談のファイル1つだけでした。テストケース表は24件で、上限の手前・ちょうど・その先などの境界値が中心でした。
- 金額は Anthropic 直販の定価で計算しています。Bedrock の料金は別なので、AWS の料金ページで確かめてください。

## 入れ方

Mac・Linux はターミナル、Windows は Git Bash で実行します（Claude Code が使っているものと同じです）。

```bash
git clone https://github.com/manochamanoty/haiku-rails.git
cd haiku-rails
bash install.sh
```

入るもの：
- `~/.claude/haiku-rails/`：共通ルール、フック、ステータスライン、設定の例
- `~/.claude/skills/` の11個のスキル
- `~/.claude/CLAUDE.md` に1行（共通ルールを読み込む `@~/.claude/haiku-rails/RULES.md`）

`settings.json` は変更しません。入れたら Claude Code を起動し直して **`/rails-setup`** を打ってください。今の設定を調べて、足りないものを提案します。書き足すのは、OKしたときだけです。

## 設定のポイント（`settings.example.json`）

- **すべて Haiku 5.5 に固定する。** Bedrock では、`haiku` の既定が Haiku 4.5、裏の処理（タイトル付けなど）の既定が Sonnet です。`ANTHROPIC_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`CLAUDE_CODE_SUBAGENT_MODEL` を Haiku 5.5 にします。
  - モデルのIDは `aws bedrock list-inference-profiles --region ap-northeast-1` で確かめます。
- **Opus は `/opus-review` だけ。** `ANTHROPIC_DEFAULT_OPUS_MODEL` を Opus 5.5 にします。
- **10万トークンの壁。** Haiku 5.5 は、1回の入力が10万トークンを超えると単価が5倍になります（直販価格）。
  - `CLAUDE_CODE_AUTO_COMPACT_WINDOW=100000` で、早めに圧縮させます。
  - ステータスラインは8万で注意を出します。
  - Claude Code の前置きだけで2〜4万トークンあるので、タスクごとの `/clear` が効きます。
- **effort。** Haiku は high にします。計画とレビューのスキルだけ、スキルの中で xhigh にしています。
  - 新しいモデルは、settings の `effortLevel` を読まないことがあります。`modelSettings` に Haiku 5.5 のIDで保存し、`/status` で確かめてください。
- **Opus の effort は high 固定。** 使うのは月に数十回で、high と medium の差は1回あたり数十円程度です。境界値の洗い出しに効くので high にしています。xhigh と max は使いません。

## Opus の安全弁

| 仕掛け | 中身 |
|---|---|
| 人しか呼べない | `/opus-review` は `disable-model-invocation: true`。Haiku が勝手に呼ぶことはありません |
| Opus のサブエージェントを作らない | 作ると Haiku が自分の判断で呼べてしまうため |
| 会話を渡さない | `context: fork`。長い会話を Opus の料金で読み直しません |
| 道具を絞る | 編集・Bash・検索・Web を禁止。試験でも、読んだのはパケット1つだけでした |
| 指示で縛る | コードを書かない、質問で返さない、範囲外の依頼には「担当外です。Haikuに戻してください」とだけ答える、4000字まで |
| 自分で守ること | 会話の途中で `/model opus` に切り替えない。それまでの会話全部が Opus の料金で読み直されます |
| お金 | AWS Budgets で、月の予算の8割になったら通知が来るようにする |

## 機械のチェック（フック）

- **テストの書き換え防止**（`/impl` の間）
  - テストのファイル（`test/`・`tests/`・`*.test.*`・`*_test.*`・`*Test.java` など）を Edit/Write しようとすると止めます。
  - Bash での書き換えは止められません（共通ルールで禁止しています）。
  - `/clear` や `/resume` で外れます。もう一度 `/impl` を打つと戻ります。
- **最後のテストの関所**
  - 作業するリポジトリに `.claude/check.sh` を置くと、計画の最後のタスクが終わったときに自動で走ります。失敗したら終わらせず、直させます（2回まで）。
  - ひな形は `~/.claude/haiku-rails/check.sh.example` です。
  - リポジトリに入れたくなければ、`.git/info/exclude` に足してください。

テストのコマンドを `/permissions` で許可しておくと、確認のたびに止まらずに済みます（例：`Bash(npm test *)`）。

## カスタマイズ

- **いちばん効くのは「良い例」を差し替えること**です。`~/.claude/skills/<名前>/references/` の例を、自分の会社の良いMR・良い課題コメント・良い計画に替えると、Haiku はその形をまねます。
  - 会社の例は、入れた先（`~/.claude/`）だけで直してください。このリポジトリは公開なので、会社の情報を push しないでください。
- スキルは `~/.claude/skills/<名前>/SKILL.md` を直接直して構いません。
  - `bash install.sh` をもう一度打つと上書きされます。前のものは `~/.claude/haiku-rails-backup/` に残ります。
  - 直したスキルを残したいときは、`bash install.sh --keep-skills` で入れます。
- 自分のルールは `~/.claude/CLAUDE.md` に書いてください。`RULES.md` は入れ直すと上書きされます。
- 同じ流れのスキル集（Superpowers・cc-sdd など）と一緒に入れると、手順がぶつかります。どちらか一方にしてください。

## 外し方

```bash
bash uninstall.sh
```

スキル・`~/.claude/haiku-rails/`・CLAUDE.md の1行を消します。`settings.json` は自分で戻してください（`/rails-setup` で作った `.bak-` のファイルが残っています）。

## 中身

```
rails/RULES.md              常に読む共通ルール
rails/hooks/                テストの書き換え防止・最後のテストの関所
rails/statusline.sh         文脈の量・費用の表示
skills/                     req, consult, opus-review, task-plan, write-tests, impl,
                            self-review, mr, backlog-note, explain, rails-setup
settings.example.json       おすすめの設定（IDは自分のものに）
templates/check.sh.example  プロジェクトの確認スクリプトのひな形
```

## 参考にしたもの

コードや文章はコピーしていません。考え方を参考にしています。

- [obra/superpowers](https://github.com/obra/superpowers)：「判断力のない人でも従える細かさ」の計画、テストを先に書く流れ
- [gotalab/cc-sdd](https://github.com/gotalab/cc-sdd)：要件 → 設計 → タスクの分け方
- [HumanLayer: Advanced Context Engineering](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)：文脈を小さく保つ
- [dashed/claude-marketplace](https://github.com/dashed/claude-marketplace) の code-walkthrough・show-me：解説HTML
- [nicobailon/visual-explainer](https://github.com/nicobailon/visual-explainer)：解説を実際のコードと照らす fact-check

## ライセンス

MIT
