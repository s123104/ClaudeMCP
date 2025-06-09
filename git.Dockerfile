FROM node:18-alpine
RUN apk add --no-cache git
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-git
CMD ["npx", "@modelcontextprotocol/server-git", "/repo"]
EXPOSE 4000
# --- Security: drop root ---
RUN groupadd -r mcp && useradd -r -g mcp -u 1000 mcp \
 && mkdir -p /workspace && chown -R mcp:mcp /workspace
USER mcp
