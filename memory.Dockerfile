FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-memory
CMD ["npx", "@modelcontextprotocol/server-memory"]
EXPOSE 4000