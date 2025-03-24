FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-everything
CMD ["npx", "@modelcontextprotocol/server-everything"]
EXPOSE 4000