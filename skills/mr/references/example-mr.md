# マージリクエストの説明の例（この書き方で書く）

タイトル：購入金額に応じた割引を注文の合計に反映（SHOP-123）

---

## 概要
購入金額が10,000円以上で5%、30,000円以上で10%、ゴールド会員はさらに2%を割り引くようにしました。
割引の計算を `calcDiscountRate` に分け、注文の合計（`calcOrderTotal`）から呼んでいます。

## 関連
- 課題：https://example.backlog.jp/view/SHOP-123

## 変更点
- `src/order/discount.ts`（新規）：割引率を決める `calcDiscountRate` を追加
- `src/order/constants.ts`：割引の境目と率を `DISCOUNT_STEPS` として追加
- `src/order/total.ts`：送料を足す前に割引を適用（端数は切り捨て）
- `src/order/discount.test.ts`（新規）：境目（9,999／10,000／29,999／30,000円）、会員、0円、負の値のテスト

## 確認したこと
- `npx vitest run src/order/discount.test.ts`：9件すべて成功
- `npm test`：既存を含め 128件すべて成功

## 影響範囲
- 注文の合計を表示・保存するすべての画面とAPI（`calcOrderTotal` の呼び出し元：`checkout.ts`・`order-api.ts`）
- 送料の計算は変えていません

## レビューしてほしい点
- ゴールド会員で割引の対象外（10,000円未満）のとき、上乗せの2%もつけない扱いにしました（課題に明記がなかったため。テスト No7）。この解釈でよいか。

## 補足
- 境界の 29,999円 のケースは、上の段（10%）に入る直前を確かめるために足しました。
- クーポンとの併用は、この課題の範囲外です（別課題で扱う想定）。
