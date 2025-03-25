#!/bin/bash

# 進到專案根目錄
cd "$(dirname "$0")/.."

echo "🚀 正在安裝 Claude Code 喔～請稍候... 💖"

# 安裝 Claude Code（避免使用 sudo）
npm install -g @anthropic-ai/claude-code

# 檢查安裝是否成功
if command -v claude &> /dev/null; then
    echo "✨ Claude Code 安裝成功啦！正在啟動並進行首次認證～"
    cd data/git  # 假設您的 Git 儲存庫在此
    claude       # 啟動 Claude Code 並完成 OAuth（若無 ANTHROPIC_API_KEY）
else
    echo "❌ 安裝失敗！請檢查 Node.js 和 npm 是否正確安裝～"
    exit 1
fi

echo "🎉 Claude Code 設置完成！可以用 'claude' 命令開始使用囉～啾啾！🐰"