FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-sequential-thinking
CMD ["npx", "@modelcontextprotocol/server-sequential-thinking"]
EXPOSE 4000