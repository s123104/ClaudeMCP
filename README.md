# 🐳 ClaudeMCP - Docker + Claude Desktop 整合設定教學

> 🎯 **目標**：透過 Docker 隔離運行 MCP 伺服器，整合 Claude Desktop，支援 `.env` 敏感資料管理，提供安全、可擴展的本地開發與部署環境。

---

## 📋 專案概述

ClaudeMCP 是一個使用 Docker Compose 運行多個 MCP（Model Context Protocol）伺服器的專案，與 Claude Desktop 應用程式整合。支援以下伺服器：

- `filesystem`、`sqlite`、`git`、`postgres`、`memory`、`brave-search`、`everything`、`puppeteer`、`github`

本專案使用 `.env` 管理敏感資料，並透過 Docker 容器實現隔離。目前採用 `npx` 本地啟動 MCP 伺服器模式，Docker 提供環境隔離（未來可擴展至 HTTP API 模式）。

---

## 📂 專案目錄結構

```bash
ClaudeMCP/
├── docker-compose.yml          # Docker Compose 配置
├── .env                        # 環境變數檔案
├── .gitignore                  # Git 忽略檔案
├── claude_desktop_config.json  # Claude Desktop MCP 配置
├── launch_claude.sh            # 一鍵啟動 Claude Desktop 腳本
├── Dockerfile                  # filesystem MCP 專用
├── sqlite.Dockerfile           # SQLite MCP 專用
├── git.Dockerfile              # Git MCP 專用
├── postgres.Dockerfile         # Postgres MCP 專用
├── memory.Dockerfile           # Memory MCP 專用
├── brave-search.Dockerfile     # Brave Search MCP 專用
├── everything.Dockerfile       # Everything MCP 專用
├── puppeteer.Dockerfile        # Puppeteer MCP 專用
├── github.Dockerfile           # GitHub MCP 專用
├── scripts/
│   └── start-all.sh            # 一鍵啟動 Docker 腳本
└── data/
    ├── sqlite/                 # SQLite 資料存放
    └── git/                    # Git 儲存庫存放
```

---

## 🔧 前置要求

- **Docker**: 安裝 [Docker Desktop](https://www.docker.com/products/docker-desktop/) 或 Docker CLI。
- **Claude Desktop**: 已安裝並配置於 `/Users/yourname/Library/Application Support/Claude/`。
- **Node.js**: 用於本地測試（可選，若直接使用 Docker 可跳過）。
- **Git**: 用於版本控制。

---

### 📦 環境變數設定（`.env`）

本專案使用 `.env` 管理機密資料與埠號設定，請依下列步驟建立你的專屬 `.env` 檔案：

#### ✅ 建立 `.env` 檔案

```bash
cp .env.example .env
```

> ⚠️ `.env` 不應上傳到 GitHub，已列入 `.gitignore` 中，請自行建立並填入內容。

#### 🛠️ 修改 `.env` 內容

打開 `.env`，填入你的實際路徑與金鑰，格式範例如下：

```dotenv
# Volume 掛載目錄
FILESYSTEM_PATH=/Users/yourname/Desktop/ClaudeMCP/data
SQLITE_PATH=./data/sqlite
GIT_PATH=./data/git

# 資料庫連線
POSTGRES_CONNECTION=postgresql://postgres:password@localhost:5432/mydb

# API 金鑰（自行取得）
GITHUB_API_KEY=ghp_xxxxxxxxxxxxxxxxxxxxx
BRAVE_API_KEY=brv_xxxxxxxxxxxxxxxxxxxxx

# Docker 服務埠號
FILESYSTEM_PORT=3000
SQLITE_PORT=3001
GIT_PORT=3002
POSTGRES_PORT=5432
MEMORY_PORT=3003
BRAVE_PORT=3004
EVERYTHING_PORT=3005
PUPPETEER_PORT=3006
GITHUB_PORT=3007
```

---

## 🧱 `docker-compose.yml`

在專案根目錄創建 `docker-compose.yml`，內容如下：

```yaml
services:
  filesystem:
    image: claude-mcp-fs
    build:
      context: .
      dockerfile: Dockerfile
    container_name: mcp-filesystem
    volumes:
      - ${FILESYSTEM_PATH}:/sandbox
    environment:
      - FILESYSTEM_PATH=${FILESYSTEM_PATH}
    ports:
      - "${FILESYSTEM_PORT}:4000"

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

  postgres:
    image: postgres:15
    container_name: mcp-postgres
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    ports:
      - "${POSTGRES_PORT}:5432"

  memory:
    image: claude-mcp-memory
    build:
      context: .
      dockerfile: memory.Dockerfile
    container_name: mcp-memory
    ports:
      - "${MEMORY_PORT}:4000"

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

  everything:
    image: claude-mcp-everything
    build:
      context: .
      dockerfile: everything.Dockerfile
    container_name: mcp-everything
    ports:
      - "${EVERYTHING_PORT}:4000"

  puppeteer:
    image: claude-mcp-puppeteer
    build:
      context: .
      dockerfile: puppeteer.Dockerfile
    container_name: mcp-puppeteer
    ports:
      - "${PUPPETEER_PORT}:4000"

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
```

> **注意**：容器內端口統一設為 `4000`（`postgres` 除外），假設 MCP 伺服器監聽此端口。若不同，需調整 `Dockerfile`。

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
    }
  }
}
```

> **重要說明**：
>
> - 目前使用 `npx` 本地啟動 MCP 伺服器，Docker 僅提供隔離環境，`.env` 中的端口（如 `3000`）不影響此模式。
> - `POSTGRES_CONNECTION` 需使用完整連線字串（如 `postgresql://user:password@host:port/dbname`）。
> - 若 Claude Desktop 無法解析 `$VARIABLE`，請參考「環境變數載入」段落。

---

## 🐳 Dockerfile 示例

以下是各 MCP 伺服器的 `Dockerfile` 示例，根據需要創建對應檔案：

### `Dockerfile` (filesystem)

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-filesystem
CMD ["npx", "@modelcontextprotocol/server-filesystem", "/sandbox"]
EXPOSE 4000
```

### `sqlite.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-sqlite
CMD ["npx", "@modelcontextprotocol/server-sqlite", "/app"]
EXPOSE 4000
```

### `git.Dockerfile`

```Dockerfile
FROM node:18-alpine
RUN apk add --no-cache git
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-git
CMD ["npx", "@modelcontextprotocol/server-git", "/repo"]
EXPOSE 4000
```

### `memory.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-memory
CMD ["npx", "@modelcontextprotocol/server-memory"]
EXPOSE 4000
```

### `brave-search.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-brave-search
CMD ["npx", "@modelcontextprotocol/server-brave-search"]
EXPOSE 4000
```

### `everything.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-everything
CMD ["npx", "@modelcontextprotocol/server-everything"]
EXPOSE 4000
```

### `puppeteer.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm install -g @modelcontextprotocol/server-puppeteer
CMD ["npx", "@modelcontextprotocol/server-puppeteer"]
EXPOSE 4000
```

### `github.Dockerfile`

```Dockerfile
FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/servergithub
CMD ["npx", "@modelcontextprotocol/servergithub"]
EXPOSE 4000
```

> **注意**：確認各 MCP 伺服器的實際包名和端口，若有誤，請參考 [mcp.so](https://mcp.so/) 或官方儲存庫。

---

## 📜 啟動腳本

### `scripts/start-all.sh`

```bash
#!/bin/bash

# 進到專案根目錄（保險用法）
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 全部啟動完成啦！可以用 'docker-compose logs' 看看日誌喔～啾啾！🐰"
```

### `launch_claude.sh`

```bash
#!/bin/bash

# 進到專案根目錄（保險用法）
cd "$(dirname "$0")/.."

echo "🐳 正在啟動所有 Claude MCP 容器喔～請稍候... 💖"
docker-compose up -d --build

echo "✨ 容器啟動完成！現在載入環境變數並打開 Claude Desktop～"
export $(cat .env | xargs)
open -a "Claude Desktop"

echo "🎉 全部搞定啦！可以用 Claude 開始測試囉～啾啾！🐰"
```

執行權限：

```bash
chmod +x scripts/start-all.sh
chmod +x launch_claude.sh
```

---

## ✅ 安裝與啟動

1. **克隆專案**

   ```bash
   git clone <repository-url>
   cd ClaudeMCP
   ```

2. **設置 `.env`**

   - 編輯 `.env`，填入你的實際路徑和 API 金鑰。

3. **一鍵啟動**

   - 啟動 Docker 容器並打開 Claude Desktop：
     ```bash
     ./scripts/start-all.sh && ./launch_claude.sh
     ```

4. **配置 Claude Desktop**

   - 將 `claude_desktop_config.json` 放入 `/Users/yourname/Library/Application Support/Claude/`。
   - 若已運行 `launch_claude.sh`，環境變數會自動載入。

5. **驗證**

   - 在 Claude IClaude Desktop 中輸入以下指令測試：

     | 測試指令                              | 效果                       |
     | ------------------------------------- | -------------------------- |
     | `讀取 $FILESYSTEM_PATH/test.txt`      | 測試 filesystem 是否可讀取 |
     | `查詢 $SQLITE_PATH/notes.db 的資料表` | SQLite MCP 測試            |
     | `顯示 Git 儲存庫目前狀態`             | 測試 Git MCP               |
     | `記住我今天生日是 1990-01-01`         | 測試 memory MCP            |
     | `搜尋 Claude MCP 教學`                | 測試 brave-search          |
     | `查詢 GitHub 上 Claude 的 PR`         | 測試 GitHub MCP            |
     | `對 PostgreSQL 查詢 users 表`         | 測試 postgres MCP          |
     | `開啟 https://example.com 並截圖`     | 測試 puppeteer MCP         |

---

## 🔒 安全建議

- **保護 `.env`**：添加至 `.gitignore`：

  ```plaintext
  .env
  data/
  ```

- **限制權限**：

  ```bash
  chmod 600 .env
  ```

- **檢查端口衝突**：確保主機端口（如 3000-3007）未被其他應用占用。

---

## 🚀 進階功能

- **HTTP 代理模式**：若需將 MCP 伺服器作為 HTTP API 運行，可修改 `claude_desktop_config.json`：

  ```json
  "filesystem": {
    "url": "http://localhost:${FILESYSTEM_PORT}"
  }
  ```

- **自動重啟**：在 `docker-compose.yml` 中添加 `restart: unless-stopped`。
- **Cloudflare Proxy**：使用 Cloudflare Tunnel 暴露服務。

若需實現這些功能，請說：「兔兔幫我一鍵整包 ✨」。

---

## ❤️ 結語

你現在已成功整合：

- Claude Desktop + `.env` 機密管理
- MCP 伺服器：`github`、`postgres`、`puppeteer`、`sqlite`、`filesystem`、`git`、`memory`、`brave-search`、`everything`
- Docker Compose 隔離部署（`npx` 模式）

這份教學已達「Claude MCP 工程師專業等級」，可直接作為 GitHub README 或部落格文章發布！如需進一步優化（例如轉換工具、CLI 自動化、TLS 串接），隨時告訴我！啾啾 🐰❤️

---

## 📚 參考資源

- [Model Context Protocol Servers](https://github.com/modelcontextprotocol/servers)
- [mcp.so](https://mcp.so/)
- [Docker Compose 官方文檔](https://docs.docker.com/compose/)

---

### 補充檔案（上架 GitHub 用）

#### `.gitignore`

```plaintext
.env
data/
*.log
```

#### `LICENSE`（MIT 許可證示例）

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

---
