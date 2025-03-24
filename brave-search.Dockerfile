FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-brave-search
CMD ["npx", "@modelcontextprotocol/server-brave-search"]
EXPOSE 4000