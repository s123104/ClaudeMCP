FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-sqlite
CMD ["npx", "@modelcontextprotocol/server-sqlite", "/app"]
EXPOSE 4000