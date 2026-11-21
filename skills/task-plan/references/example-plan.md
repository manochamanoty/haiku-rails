# 計画の例（この細かさで書く）

> これは書き方の見本。中身（ファイル名・関数名）は実際のプロジェクトに合わせる。

---

# 計画：購入金額に応じた割引を、注文の合計に反映する

## 方針（3行まで）
- 割引の計算は新しい関数 `calcDiscountRate` に分け、`calcOrderTotal` から呼ぶ。
- 既存の送料計算（`calcShipping`）と同じ書き方（純粋関数＋定数は `constants.ts`）に合わせる。
- 金額は円の整数。割引後の端数は切り捨て（受け入れ条件3）。

## テストの実行方法
- 全部：`npm test`
- 1ファイル：`npx vitest run src/order/discount.test.ts`

## テストケース表
| No | 対象 | 観点 | 入力 | 期待する結果 | 仕様のどこ |
|---|---|---|---|---|---|
| 1 | calcDiscountRate | 正常 | 小計 20000円・一般 | 0.05 | 受け入れ条件1 |
| 2 | calcDiscountRate | 境界 | 小計 9999円・一般 | 0 | 受け入れ条件1 |
| 3 | calcDiscountRate | 境界 | 小計 10000円・一般 | 0.05 | 受け入れ条件1 |
| 4 | calcDiscountRate | 境界 | 小計 29999円・一般 | 0.05 | 受け入れ条件2 |
| 5 | calcDiscountRate | 境界 | 小計 30000円・一般 | 0.10 | 受け入れ条件2 |
| 6 | calcDiscountRate | 分岐 | 小計 10000円・ゴールド会員 | 0.07 | 受け入れ条件4 |
| 7 | calcDiscountRate | 分岐 | 小計 9999円・ゴールド会員 | 0（仮定：会員の上乗せは割引がある時だけ） | 受け入れ条件4 |
| 8 | calcDiscountRate | 空 | 小計 0円 | 0 | 受け入れ条件1 |
| 9 | calcDiscountRate | 異常 | 小計 -1円 | RangeError | 受け入れ条件5 |
| 10 | calcOrderTotal | 正常 | 小計 10001円・一般・送料 0円 | 9500円（10001×0.95=9500.95 の切り捨て） | 受け入れ条件3 |

## タスク
- [ ] T1：割引率を決める関数を作る
  - 触るファイル：`src/order/discount.ts`（新規）、`src/order/constants.ts`
  - お手本：`src/order/shipping.ts`：`calcShipping`
  - やること：`calcDiscountRate(subtotal: number, rank: "normal" | "gold"): number` を作る。境目（10000・30000）と率は `constants.ts` に `DISCOUNT_STEPS` として置く。小計が負なら `RangeError("subtotal must be >= 0")`。
  - 対応するテスト：No 1〜9
  - 確認コマンド：`npx vitest run src/order/discount.test.ts`
  - 終わりの条件：No 1〜9 が通る
- [ ] T2：注文の合計に割引を反映する
  - 触るファイル：`src/order/total.ts`
  - お手本：同じファイルの送料の足し方
  - やること：`calcOrderTotal` で、送料を足す前に `Math.floor(subtotal * (1 - rate))` を適用する。
  - 対応するテスト：No 10
  - 確認コマンド：`npx vitest run src/order/total.test.ts` と `npm test`
  - 終わりの条件：No 10 と既存のテストが全部通る

## 気づいたこと

## 実装メモ
