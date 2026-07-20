# CLAUDE.md — 給接手這個專案的 Claude

## 使用者背景（重要，先讀）

- 老闆是 Tony（GitHub: seethelight-tony，email: antonyw829@gmail.com），**非工程師**，用繁體中文溝通、講人話、避免術語
- 品牌：極光盾 NORTHSHIELD（能量淨化生活用品：淨化沐浴包、噴霧、薰香粉、飾品），主要賣場是蝦皮和官網 seethelight.shop
- Tony 偏好在對話中直接操作，不要叫他自己寫程式或下指令；能自動做的就自動做

## 這個專案是什麼

「產品圖工作室」：上傳 1〜3 張隨手拍產品照＋產品說明 → AI 生成電商上架圖（白底主圖／生活情境圖／質感氛圍圖，1:1／3:4／16:9）。

- **線上版**：https://seethelight-tony.github.io/product-photo-studio/ （GitHub Pages，push 到 main 後約 1 分鐘自動更新）
- **本機版**：點兩下 `啟動.bat`（Python http.server，port 8899）

## 技術架構

- 純前端單檔 `index.html`，無後端；API 金鑰存瀏覽器 localStorage（`pps_api_key`＝Gemini、`pps_openai_key`＝OpenAI），**換電腦要重新貼金鑰**（金鑰本身跨機共用）
- 雙引擎：
  - Gemini：`generativelanguage.googleapis.com/v1beta/models/<model>:generateContent?key=`，模型 `gemini-2.5-flash-image`（標準）／`gemini-3-pro-image-preview`（高品質）；帶 `generationConfig.imageConfig.aspectRatio`，400 就退回無 imageConfig 重試
  - OpenAI：`api.openai.com/v1/images/edits`（FormData），模型 `gpt-image-1.5`（medium）／`gpt-image-2`（high）；瀏覽器直呼、CORS 可行
- 429 處理：解析回應 details 裡的 QuotaFailure.quotaValue——`0`＝免費層未開放（2026-07 實測兩家生圖 API 都無免費額度，需計費），`>0`＝當日用完
- 「🔍 測試金鑰」按鈕：文字模型驗 Gemini 金鑰有效性→生圖模型探額度；OpenAI 用 GET /v1/models 驗

## 目前主力產線（2026-07-07 Tony 拍板）

**Gemini／網頁工具已停用**，生圖一律走下方「指揮官模式」（Codex 用 ChatGPT 訂閱額度，不另外花錢）。index.html 網頁工具保留但不再是主線。

## 指揮官模式（Claude 指揮 Codex 生圖）— 2026-07-07 已實測成功

Tony 設定：**Claude＝指揮官（寫 brief、驗收品管）、Codex＝執行手（生圖）**。Codex CLI 內建 $imagegen（gpt-image-2），走 Tony 的 ChatGPT 訂閱額度、不另外計費（額度消耗比純文字快 3〜5 倍）。

執行方式（Windows PowerShell）：

```powershell
# codex.exe 不在 PATH，在這個模式的資料夾下（hash 目錄名會隨版本變，用萬用字元找）：
$codex = (Get-ChildItem "$env:LOCALAPPDATA\OpenAI\Codex\bin\*\codex.exe" | Select-Object -First 1).FullName
# 關鍵地雷：stdin 必須用管線關閉，否則 codex exec 會停在「Reading additional input from stdin...」卡死
'' | & $codex exec --skip-git-repo-check --sandbox workspace-write -C <工作資料夾> "<英文 brief，指名用 `$imagegen 並存檔到指定檔名>"
# 產品照輸入加 -i <照片路徑>；生成的圖同時留底在 ~\.codex\generated_images\<session>\
```

**已知地雷（2026-07-07 家用電腦實測）**：

1. 這台機器的 codex exec 沙盒實際跑成 read-only（`--sandbox workspace-write` 沒生效），Codex 生完圖無法自己存到指定資料夾。解法：從 codex 輸出裡抓 session id，由 Claude 自己去 `~\.codex\generated_images\<session id>\` 把 PNG 複製到目標位置。
2. **改圖（-i）時 prompt 要走 stdin**：加了 `-i` 後位置參數的 prompt 會讀不到，要把 brief 用管線餵進去＋結尾加 `-`：`$brief | & $codex exec ... -i <照片> -`
3. **stdin 管線會把中文變亂碼**（PowerShell 5.1 編碼問題）——brief 一律純英文寫；標籤文字保留就寫「preserve ALL label text character-for-character, do NOT redraw」，以輸入照片為準，實測有效。

流程：Claude 寫英文 brief（含下方品牌紅線）→ codex exec → Claude 用 Read 打開圖片驗收 → 不合格重下指令 → 合格才交 Tony。

## 品牌知識來源：第二大腦（生圖前先查，家用電腦路徑 `C:\第二大腦`）

Tony 的 Obsidian 知識庫（Google Drive 鏡像），品牌與產品知識、文案邊界的權威來源。**寫生圖 brief 或圖上文案前先讀相關檔案**：

| 要查什麼 | 檔案 |
|---|---|
| 總入口／地圖 | `C:\第二大腦\首頁.md` |
| **蝦皮賣場原始素材**（各商品資料夾、PSD、文案 docx） | `C:\第二大腦\極光盾\蝦皮賣場\`——改舊圖一律從這拿原始檔 |
| **Codex 跨機工作區**（loop 筆記、分析框架、產出備份） | `C:\第二大腦\_codex\`（=雲端 `G:\我的雲端硬碟\_codex`），入口 `PROJECT_INDEX.md`；每次商品圖任務後回寫 worklog |
| **文案能不能這樣寫（四不＋合規句型，圖上有字必查）** | `極光盾\品牌資料庫\文案內容室\language_boundary_rules.md` |
| 法規禁用詞分級 | `極光盾\品牌資料庫\文案內容室\極光盾_法規合規審核準則_v1_4.md` |
| 受眾是誰 | `極光盾\影片中心\品牌文件\受眾輪廓.md` |
| 產品角色／導購定位 | `極光盾\影片中心\品牌文件\商品角色表.md` |
| 品牌語氣 | `極光盾\影片中心\設定檔\語氣.md`、`極光盾\社群發文\語氣檔.md` |

文案四不（圖上文字同樣適用）：不放大恐懼、不承諾結果（轉運招財）、不神化產品、不寫醫療或人體效果（安神舒緩助眠都不行）。

**Loop 優化**：每次生圖實戰後，把驗收心得（哪種 brief 寫法有效、哪種場景賣相好）回寫到本檔或第二大腦對應筆記，讓下一輪更準。

## 圖片風格與圖庫管理（2026-07-07 起）

- **風格權威文件：`圖片風格指南.md`**（UNIQLO 式方法 × 極光盾暖色調）——生圖 brief 前必讀
- 圖庫流程：新圖進 `圖庫\01_討論中\` → 逐圖討論（附風格說明＋圖上文案＋功能定位）→ 定稿搬 `圖庫\02_定稿\<商品>\`，淘汰即刪
- 命名：`商品_用途_日期_v版本.png`；01_討論中與測試輸出不進 git（見 .gitignore）

## 極光盾品牌紅線（生圖 brief 必守）

- 溫和、柔和、有安全感；暖色調（米白／奶油／晨光），可點綴品牌黃 `#e6ca5c`
- **禁止**：黑暗、恐怖、高對比黑底、恐懼式意象（品牌主張「不販賣恐懼」）
- 產品實拍改圖時：形狀、比例、顏色、包裝、**標籤文字**必須與原照一致，絕不可重畫或發明文字
- 品牌字體 Noto Sans TC；受眾以 35-44 女性、敏感體質族群為主

## 已談過的下一步構想（Tony 尚未拍板）

- 批次模式（一次多商品）
- 農曆七月檔期視覺模板（2026/8/13 起、中元 8/27，7 月下旬要預熱）
- 固定場景模板（浴室木架、玄關等常用場景重複使用)
- 指揮官模式實戰：拿真實產品照跑「改圖」全流程（-i 輸入照片）
  - 2026-07-07 已完成純生成測試（`測試輸出\test_01.png`，通過品牌驗收）；改圖實戰待真實產品照
