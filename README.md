# 🐳 ClaudeMCP - Docker + Claude Desktop 整合設定教學

> 🎯 **目標**：透過 Docker 隔離運行 MCP 伺服器，整合 Claude Desktop 和 Claude Code，並支援 GitLab 項目管理、時間轉換等功能，使用 `.env` 管理敏感資料，提供安全、可擴展的本地開發與部署環境，並支援結構化思考與自然語言編碼工作流。

---

## 📋 專案概述

`ClaudeMCP` 是一個使用 Docker Compose 運行多個 MCP（Model Context Protocol）伺服器的專案，與 Claude Desktop 應用程式和 Claude Code 終端工具整合。本專案旨在提供一個安全、高效的本地開發環境，支援以下功能：

- **Claude Desktop**：與 MCP 伺服器互動，處理文件、資料庫、搜尋、時間轉換等任務。
- **Claude Code**：終端中的 AI 編碼助手，理解程式碼庫並執行自然語言命令。
- **多功能 MCP 伺服器**：包括 GitLab 項目管理、時間查詢與轉換、結構化思考等。

支援的 MCP 伺服器包括：

- `filesystem`、`sqlite`、`git`、`postgres`、`memory`、`brave-search`、`everything`、`puppeteer`、`github`、`sequential-thinking`、`gitlab`、`time`

本專案使用 `.env` 管理敏感資料，並透過 Docker 容器實現隔離。目前採用 `npx` 本地啟動 MCP 伺服器模式，未來可擴展至 HTTP API 模式。

---
## 🔐 2025-06 安全升級
此版本引入「mcp-isolated」專用網路與最低權限執行基線：
1. 服務僅能於內網互通，避免橫向移動。
2. 以 UID/GID 1000 非 root 帳號、唯讀根 FS、最小 capabilities、Docker 預設 Seccomp/AppArmor 運行。
3. 每台容器預設 CPU=1、RAM=512 MB，上線即符合 CIS-Docker Benchmark 1.5、1.6、2.x 規範。


## 📂 專案目錄結構

```bash
ClaudeMCP/
├── docker-compose.yml          # Docker Compose 配置
├── .env                        # 環境變數檔案
├── .env.example                # 環境變數範例檔案
├── .gitignore                  # Git 忽略檔案
├── claude_desktop_config.json  # Claude Desktop MCP 配置
├── launch_claude.sh            # 一鍵啟動 Claude Desktop 腳本
├── filesystem.Dockerfile       # filesystem MCP 專用
├── sqlite.Dockerfile           # SQLite MCP 專用
├── git.Dockerfile              # Git MCP 專用
├── postgres.Dockerfile         # Postgres MCP 專用
├── memory.Dockerfile           # Memory MCP 專用
├── brave-search.Dockerfile     # Brave Search MCP 專用
├── everything.Dockerfile       # Everything MCP 專用
├── puppeteer.Dockerfile        # Puppeteer MCP 專用
├── github.Dockerfile           # GitHub MCP 專用
├── sequential-thinking.Dockerfile  # Sequential Thinking MCP 專用
├── gitlab.Dockerfile           # GitLab MCP 專用
├── time.Dockerfile             # Time MCP 專用
├── scripts/
│   ├── start-all.sh            # 一鍵啟動 Docker 腳本
│   └── setup-claude-code.sh    # 安裝與配置 Claude Code 腳本
└── data/
    ├── sqlite/                 # SQLite 資料存放
    └── git/                    # Git 儲存庫存放
```

---

## 🔧 前置要求

- **Docker**: 安裝 [Docker Desktop](https://www.docker.com/products/docker-desktop/) 或 Docker CLI。
- **Claude Desktop**: 已安裝並配置於 `/Users/yourname/Library/Application Support/Claude/`。
- **Node.js**: 版本 18+，用於運行 Claude Code 及本地測試。
- **Git**: 用於版本控制及 Claude Code 的 Git 工作流。
- **npm**: Node.js 的套件管理器，用於安裝 Claude Code。

---

## 📦 環境變數設定（`.env`）

本專案使用 `.env` 管理機密資料與埠號設定，請依下列步驟建立您的 `.env` 檔案：

### ✅ 建立 `.env` 檔案

```bash
cp .env.example .env
```

> ⚠️ **注意**：`.env` 不應上傳至 GitHub，已列入 `.gitignore`，請自行建立並填入內容。

### 🛠️ `.env.example` 內容

```dotenv
# Volume 掛載目錄
# 指定本地檔案系統路徑，供 filesystem、sqlite 和 git MCP 使用
FILESYSTEM_PATH=/Users/yourname/Desktop/ClaudeMCP/data
SQLITE_PATH=./data/sqlite
GIT_PATH=./data/git

# 資料庫連線
# PostgreSQL 連線字串，格式為 postgresql://user:password@host:port/dbname
POSTGRES_CONNECTION=postgresql://postgres:password@localhost:5432/mydb

# API 金鑰（自行取得）
# GitHub API 金鑰，從 https://github.com/settings/tokens 獲取
GITHUB_API_KEY=ghp_xxxxxxxxxxxxxxxxxxxxx
# Brave Search API 金鑰，從 https://brave.com/search/api/ 獲取
BRAVE_API_KEY=brv_xxxxxxxxxxxxxxxxxxxxx
# Anthropic API 金鑰（可選），從 https://console.anthropic.com 獲取，若未填寫 Claude Code 將使用 OAuth 驗證
ANTHROPIC_API_KEY=sk_xxxxxxxxxxxxxxxxxxxxx
# GitLab Personal Access Token，從 https://gitlab.com/-/profile/personal_access_tokens 獲取，需包含 api、read_repository、write_repository 權限
GITLAB_PERSONAL_ACCESS_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx

# Docker 服務埠號
# 每個 MCP 伺服器分配一個獨立端口，從 3000 開始依序排列，Postgres 使用標準端口 5432
FILESYSTEM_PORT=3000
SQLITE_PORT=3001
GIT_PORT=3002
MEMORY_PORT=3003
BRAVE_PORT=3004
EVERYTHING_PORT=3005
PUPPETEER_PORT=3006
GITHUB_PORT=3007
SEQUENTIAL_THINKING_PORT=3008
GITLAB_PORT=3009
TIME_PORT=3010
POSTGRES_PORT=5432
```

> **說明**：
>
> - `ANTHROPIC_API_KEY` 是可選的，若未填寫，Claude Code 將使用 OAuth 驗證。
> - `GITLAB_PERSONAL_ACCESS_TOKEN` 是 GitLab MCP 的必須金鑰。
> - 端口從 `3000` 到 `3010` 依序分配，`POSTGRES_PORT` 保留標準 `5432`。

---

## 🧱 `docker-compose.yml`

在專案根目錄創建 `docker-compose.yml`，內容如下：

```yaml
services:
  filesystem:
    image: claude-mcp-fs
    build:
      context: .
      dockerfile: filesystem.Dockerfile
    container_name: mcp-filesystem
    volumes:
      - ${FILESYSTEM_PATH}:/sandbox
    environment:
      - FILESYSTEM_PATH=${FILESYSTEM_PATH}
    ports:
      - "${FILESYSTEM_PORT}:4000"
    restart: unless-stopped

  sqlite:
    image: claude-mcp-sqlite
    build:
      context: .
      dockerfile: sqlite.Dockerfile
    container_name: mcp-sqlite
    volumes:
      - ${SQLITE_PATH}:/app
    environment:
      - SQLITE_PATH=${SQLITE_PATH}
    ports:
      - "${SQLITE_PORT}:4000"
    restart: unless-stopped

  git:
    image: claude-mcp-git
    build:
      context: .
      dockerfile: git.Dockerfile
    container_name: mcp-git
    volumes:
      - ${GIT_PATH}:/repo
    environment:
      - GIT_PATH=${GIT_PATH}
    ports:
      - "${GIT_PORT}:4000"
    restart: unless-stopped

  postgres:
    image: claude-mcp-postgres
    build:
      context: .
      dockerfile: postgres.Dockerfile
    container_name: mcp-postgres
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "${POSTGRES_PORT}:5432"
    restart: unless-stopped

  memory:
    image: claude-mcp-memory
    build:
      context: .
      dockerfile: memory.Dockerfile
    container_name: mcp-memory
    ports:
      - "${MEMORY_PORT}:4000"
    restart: unless-stopped

  brave-search:
    image: claude-mcp-brave-search
    build:
      context: .
      dockerfile: brave-search.Dockerfile
    container_name: mcp-brave-search
    environment:
      - BRAVE_API_KEY=${BRAVE_API_KEY}
    ports:
      - "${BRAVE_PORT}:4000"
    restart: unless-stopped

  everything:
    image: claude-mcp-everything
    build:
      context: .
      dockerfile: everything.Dockerfile
    container_name: mcp-everything
    ports:
      - "${EVERYTHING_PORT}:4000"
    restart: unless-stopped

  puppeteer:
    image: claude-mcp-puppeteer
    build:
      context: .
      dockerfile: puppeteer.Dockerfile
    container_name: mcp-puppeteer
    ports:
      - "${PUPPETEER_PORT}:4000"
    restart: unless-stopped

  github:
    image: claude-mcp-github
    build:
      context: .
      dockerfile: github.Dockerfile
    container_name: mcp-github
    environment:
      - GITHUB_API_KEY=${GITHUB_API_KEY}
    ports:
      - "${GITHUB_PORT}:4000"
    restart: unless-stopped

  sequential-thinking:
    image: claude-mcp-sequential-thinking
    build:
      context: .
      dockerfile: sequential-thinking.Dockerfile
    container_name: mcp-sequential-thinking
    ports:
      - "${SEQUENTIAL_THINKING_PORT}:4000"
    restart: unless-stopped

  gitlab:
    image: claude-mcp-gitlab
    build:
      context: .
      dockerfile: gitlab.Dockerfile
    container_name: mcp-gitlab
    environment:
      - GITLAB_PERSONAL_ACCESS_TOKEN=${GITLAB_PERSONAL_ACCESS_TOKEN}
      - GITLAB_API_URL=https://gitlab.com/api/v4
    ports:
      - "${GITLAB_PORT}:4000"
    restart: unless-stopped

  time:
    image: claude-mcp-time
    build:
      context: .
      dockerfile: time.Dockerfile
    container_name: mcp-time
    ports:
      - "${TIME_PORT}:4000"
    restart: unless-stopped
```

> **注意**：容器內端口統一設為 `4000`（`postgres` 除外），假設 MCP 伺服器監聽此端口。若不同，需調整對應 `Dockerfile`。

---

## ⚙️ `claude_desktop_config.json`

將以下內容放入 `/Users/yourname/Library/Application Support/Claude/claude_desktop_config.json`：

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$FILESYSTEM_PATH"
      ]
    },
    "sqlite": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sqlite", "$SQLITE_PATH"]
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git", "$GIT_PATH"]
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "$POSTGRES_CONNECTION"
      ]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/servergithub"],
      "env": {
        "GITHUB_API_KEY": "$GITHUB_API_KEY"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "$BRAVE_API_KEY"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "everything": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-everything"]
    },
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gitlab"],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "$GITLAB_PERSONAL_ACCESS_TOKEN",
        "GITLAB_API_URL": "https://gitlab.com/api/v4"
      }
    },
    "time": {
      "command": "npx",
      "args": ["-y", "mcp-server-time"]
    }
  }
}
```

> **重要說明**：
>
> - 使用 `npx` 本地啟動 MCP 伺服器，Docker 提供隔離環境，`.env` 中的端口不影響此模式。
> - `GITLAB_PERSONAL_ACCESS_TOKEN` 為必須，若未提供，GitLab MCP 將無法運作。

---

## 🐳 Dockerfile 示例

以下是部分 MCP 伺服器的 `Dockerfile` 示例：

### `filesystem.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-filesystem
CMD ["npx", "@modelcontextprotocol/server-filesystem", "/sandbox"]
EXPOSE 4000
```

### `postgres.Dockerfile`

```Dockerfile
FROM postgres:15
ENV POSTGRES_DB=mydb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
EXPOSE 5432
```

### `sequential-thinking.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-sequential-thinking
CMD ["npx", "@modelcontextprotocol/server-sequential-thinking"]
EXPOSE 4000
```

### `gitlab.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-gitlab
CMD ["npx", "@modelcontextprotocol/server-gitlab"]
EXPOSE 4000
```

### `time.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g mcp-server-time
CMD ["npx", "mcp-server-time"]
EXPOSE 4000
```

> **注意**：確認各 MCP 伺服器的實際包名和端口，若有誤，請參考 [mcp.so](https://mcp.so/) 或官方儲存庫。

---

## 📜 啟動腳本

### `scripts/start-all.sh`

```bash
#!/bin/bash

# 進到專案根目錄
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 全部啟動完成啦！可以用 'docker-compose logs' 看看日誌喔～啾啾！🐰"
```

### `scripts/setup-claude-code.sh`

```bash
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
```

### `launch_claude.sh`

```bash
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
```

執行權限：

```bash
chmod +x scripts/start-all.sh
chmod +x scripts/setup-claude-code.sh
chmod +x launch_claude.sh
```

---

## ✅ 安裝與啟動

1. **克隆專案**

   ```bash
   git clone https://github.com/s123104/ClaudeMCP
   cd ClaudeMCP
   ```

2. **設置 `.env`**

   - 編輯 `.env`，填入您的實際路徑和 API 金鑰。

3. **安裝 Claude Code**

   ```bash
   ./scripts/setup-claude-code.sh
   ```

4. **一鍵啟動**

   - 啟動 Docker 容器並打開 Claude Desktop：
     ```bash
     ./scripts/start-all.sh && ./launch_claude.sh
     ```

5. **配置 Claude Desktop**

   - 將 `claude_desktop_config.json` 放入 `/Users/yourname/Library/Application Support/Claude/`。

6. **驗證**

   - 在 Claude Desktop 或終端測試以下指令：

     | 測試指令                                       | 工具                      | 效果                       |
     | ---------------------------------------------- | ------------------------- | -------------------------- |
     | `讀取 $FILESYSTEM_PATH/test.txt`               | MCP (filesystem)          | 測試 filesystem 是否可讀取 |
     | `查詢 $SQLITE_PATH/notes.db 的資料表`          | MCP (sqlite)              | SQLite MCP 測試            |
     | `顯示 Git 儲存庫目前狀態`                      | MCP (git)                 | 測試 Git MCP               |
     | `記住我今天生日是 1990-01-01`                  | MCP (memory)              | 測試 memory MCP            |
     | `搜尋 Claude MCP 教學`                         | MCP (brave-search)        | 測試 brave-search          |
     | `查詢 GitHub 上 Claude 的 PR`                  | MCP (github)              | 測試 GitHub MCP            |
     | `對 PostgreSQL 查詢 users 表`                  | MCP (postgres)            | 測試 postgres MCP          |
     | `開啟 https://example.com 並截圖`              | MCP (puppeteer)           | 測試 puppeteer MCP         |
     | `提交我的變更`                                 | Claude Code               | 測試 Git 提交功能          |
     | `解釋這專案的結構`                             | Claude Code               | 測試程式碼理解能力         |
     | `將問題分解為步驟：如何實現用戶認證`           | MCP (sequential-thinking) | 測試結構化思考能力         |
     | `在 GitLab 項目 myproject 上創建文件 test.txt` | MCP (gitlab)              | 測試 GitLab 文件創建       |
     | `現在東京是幾點？`                             | MCP (time)                | 測試時間查詢功能           |

---

## 🔒 安全建議

- **保護 `.env`**：

  - 添加至 `.gitignore`：
    ```plaintext
    .env
    data/
    *.log
    ```
  - 限制權限：
    ```bash
    chmod 600 .env
    ```

- **Claude Code 權限**：

  - 避免使用 `sudo` 安裝，若遇權限問題：
    ```bash
    mkdir ~/.npm-global
    npm config set prefix '~/.npm-global'
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
    npm install -g @anthropic-ai/claude-code
    ```

- **網絡配置**：

  - Claude Code 需訪問 `api.anthropic.com`、`statsig.anthropic.com` 和 `sentry.io`。
  - GitLab MCP 需訪問 `https://gitlab.com/api/v4`（或自訂 URL）。

- **檢查端口衝突**：
  - 確保主機端口（如 3000-3010、5432）未被其他應用占用。

---

## 🚀 進階功能

- **HTTP 代理模式**：

  - 修改 `claude_desktop_config.json`，例如：
    ```json
    "gitlab": {
      "url": "http://localhost:${GITLAB_PORT}"
    }
    ```

- **Cloudflare Proxy**：
  - 使用 Cloudflare Tunnel 暴露服務。

---

## ❤️ 結語

您現在已成功整合：

- **Claude Desktop** + `.env` 機密管理
- **MCP 伺服器**：`github`、`postgres`、`puppeteer`、`sqlite`、`filesystem`、`git`、`memory`、`brave-search`、`everything`、`sequential-thinking`、`gitlab`、`time`
- **Claude Code**：終端中的 AI 編碼助手
- **Docker Compose**：隔離部署（`npx` 模式）

此專案提供 GitLab 項目管理、時間轉換、結構化思考與自然語言編碼支持，適合多功能開發與自動化工作流。

---

## 📚 參考資源

- [Claude Code 官方文檔](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)
- [Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)
- [mcp.so](https://mcp.so/)
- [Docker Compose 官方文檔](https://docs.docker.com/compose/)

---

## 補充檔案（上架 GitHub 用）

### `.gitignore`

```gitignore
# 環境變數檔案（包含敏感資料）
.env

# 本地資料目錄（運行時生成）
data/
data/sqlite/
data/git/

# Docker 相關
*.log
docker-compose.logs
Dockerfile.*
.dockerignore

# 編輯器或系統生成的臨時檔案
*.swp
*~
.DS_Store
Thumbs.db

# Node.js 相關（若有本地安裝）
node_modules/
npm-debug.log
package-lock.json
yarn.lock

# 其他可能的臨時檔案
*.bak
*.tmp

# Claude Desktop 配置（若本地測試）
claude_desktop_config.local.json

# Claude Code 相關（若本地生成）
.claude/

# 測試與構建產物
dist/
build/
*.tgz

# 常用編輯器與 IDE 配置
.vscode/
.idea/
*.sublime-*
*.code-workspace

# Python 相關（若涉及本地開發）
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
.virtualenv/
.env/
pip-log.txt
pip-delete-this-directory.txt

# 測試相關
coverage/
*.coverage
.coverage.*
.cache/
pytest_cache/
*.xml
*.junit

# CI/CD 配置與產物
.github/
.gitlab-ci.yml
.circleci/
.travis.yml
*.retry

# 日誌與調試檔案
*.log.*
debug.log
error.log
trace.log

# 系統快取與備份
*.bak.*
*.cache
*.orig

# 壓縮檔案與臨時下載
*.zip
*.tar.gz
*.rar
*.7z
*.dmg
*.iso

# 本地資料庫測試檔案
*.db
*.sqlite3
*.sql
*.dump

# TypeScript 相關
*.tsbuildinfo
```

### `LICENSE`（MIT 許可證）

```plaintext
MIT License

Copyright (c) 2025 [s123104]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
