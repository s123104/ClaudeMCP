#!/bin/bash

# 進到專案根目錄
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 容器啟動完成！現在載入環境變數並準備啟動 Claude Desktop 和 Claude Code～"
export $(cat .env | xargs)

# 檢查 Claude Code 是否已安裝，若未安裝則執行安裝腳本
if ! command -v claude &> /dev/null; then
    echo "⚠️ 未找到 Claude Code，正在執行安裝腳本～"
    ./scripts/setup-claude-code.sh
fi

echo "🚀 啟動 Claude Desktop～"
open -a "Claude Desktop"

echo "🎉 全部搞定啦！可以用 Claude Desktop 或終端輸入 'claude' 開始測試囉～啾啾！🐰"