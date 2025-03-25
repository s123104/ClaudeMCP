#!/bin/bash

# 進到專案根目錄
cd "$(dirname "$0")/.."

echo "🧹 正在清理 Docker 日誌喔～請稍候... 💖"

# 保留最近 100 行日誌並輸出到 logs.txt
docker-compose logs --tail=100 > logs.txt

# 清理 Docker 容器日誌（需要 root 權限）
echo "⚠️ 清理容器日誌需要管理員權限，請輸入密碼（若需要）："
sudo truncate -s 0 /var/lib/docker/containers/*/*-json.log

# 清理本地日誌檔案
find . -name "*.log" -exec truncate -s 0 {} \;

echo "✨ 日誌清理完成啦！最近的日誌已保存至 logs.txt～啾啾！🐰"