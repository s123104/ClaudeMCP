FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-filesystem
CMD ["npx", "@modelcontextprotocol/server-filesystem", "/sandbox"]
EXPOSE 4000