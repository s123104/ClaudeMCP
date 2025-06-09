FROM node:18-alpine
WORKDIR /app
RUN npm install -g mcp-server-time
CMD ["npx", "mcp-server-time"]
EXPOSE 4000
# --- Security: drop root ---
RUN groupadd -r mcp && useradd -r -g mcp -u 1000 mcp \
 && mkdir -p /workspace && chown -R mcp:mcp /workspace
USER mcp
