FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/servergithub
CMD ["npx", "@modelcontextprotocol/servergithub"]
EXPOSE 4000