FROM node:18-alpine
WORKDIR /app
RUN npm install -g mcp-server-time
CMD ["npx", "mcp-server-time"]
EXPOSE 4000