# 極光盾・產品圖工作室

上傳一張隨手拍的產品照片＋產品說明，AI 自動生成電商上架用的專業商品圖。**雙引擎**：Google Gemini 與 OpenAI GPT 都能用，同一張照片可以兩邊各生一張互相比較：

- **白底商品圖** — 蝦皮／momo 主圖用
- **生活情境圖** — 使用場景示意
- **質感氛圍圖** — 品牌感、廣告素材用

內建「極光盾品牌風格」：溫和、柔和、暖色調、品牌黃 #e6ca5c，不出現黑暗恐怖意象。

## 第一次使用（只要做一次）

**Gemini 金鑰（必備）**

1. 打開 <https://aistudio.google.com/apikey>，用 Google 帳號登入
2. 按 **Create API key**，複製那串 `AIza` 開頭的金鑰
3. 貼到工具「步驟 1」的 Gemini 欄位，按 **儲存**（需對專案開啟計費）

**OpenAI 金鑰（想用 GPT 模型才需要）**

1. 打開 <https://platform.openai.com/api-keys> 建立金鑰（`sk-` 開頭）
2. 到 Billing 儲值（最低 US$5）；部分模型需在 Settings → Organization 完成驗證
3. 貼到工具的 OpenAI 欄位按 **儲存**

金鑰只存在你自己電腦的瀏覽器裡，不會上傳到任何地方。

## 平常怎麼用

1. 到專案資料夾點兩下 **啟動.bat**（會自動打開瀏覽器）
2. 上傳 1〜3 張產品照（多角度更好）
3. 填產品名稱＋說明
4. 勾選要的圖片類型 → 按 **生成產品圖**
5. 滿意就按下載，不滿意按「重生成」

## 費用說明

- 兩家的 API 都要付費（2026-07 實測：生圖 API 都沒有免費額度），單價如下：
  - Gemini 標準約 **NT$1.2／張**、高品質約 **NT$4〜8／張**
  - GPT 標準（gpt-image-1.5）約 **NT$1.3／張**、旗艦（gpt-image-2）約 **NT$3〜7／張**
- 怕花費失控：Google 可到 [Cloud 帳單](https://console.cloud.google.com/billing) 設預算提醒；OpenAI 是預儲值制，用完自動停

## 常見問題

| 狀況 | 處理方式 |
|---|---|
| 顯示「金鑰不正確」 | 回步驟 1 重新複製貼上，注意不要少字 |
| 顯示「額度不足／用完」 | 代表金鑰所屬專案尚未開啟付費，到 aistudio.google.com 啟用計費即可 |
| 顯示「模型不可用」 | 在步驟 4 換另一個 AI 模型 |
| 圖上的字歪掉 | AI 對小字還不完美；重生成幾次，或選「高品質」模型 |

## 技術說明（給工程師看的）

純前端單頁應用（`index.html`），瀏覽器直接呼叫 Gemini API（`gemini-2.5-flash-image` / `gemini-3-pro-image-preview` 的 `generateContent`）或 OpenAI API（`gpt-image-1.5` / `gpt-image-2` 的 `/v1/images/edits`）做 image-to-image 生成。無後端、無資料庫；API 金鑰存於 `localStorage`。`啟動.bat` 用 Python 內建 `http.server` 起本機伺服器。
