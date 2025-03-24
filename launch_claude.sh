#!/bin/bash

# 進到專案根目錄（保險用法）
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 容器啟動完成！現在載入環境變數並打開 Claude Desktop～"
export $(cat .env | xargs)
open -a "Claude Desktop"

echo "🎉 全部搞定啦！可以用 Claude 開始測試囉～啾啾！🐰"