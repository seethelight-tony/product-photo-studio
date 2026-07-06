@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo.
echo   極光盾．產品圖工作室 啟動中...
echo   （這個黑色視窗要保持開著，關掉網頁就不能用囉）
echo.
start "" http://localhost:8899/
python -m http.server 8899
