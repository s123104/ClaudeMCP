FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-gitlab
CMD ["npx", "@modelcontextprotocol/server-gitlab"]
EXPOSE 4000