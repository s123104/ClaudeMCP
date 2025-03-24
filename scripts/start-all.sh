#!/bin/bash

# 進到專案根目錄（保險用法）
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 全部啟動完成啦！可以用 'docker-compose logs' 看看日誌喔～啾啾！🐰"