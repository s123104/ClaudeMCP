FROM node:18-alpine
RUN apk add --no-cache git
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-git
CMD ["npx", "@modelcontextprotocol/server-git", "/repo"]
EXPOSE 4000