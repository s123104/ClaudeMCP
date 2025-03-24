FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache chromium
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
RUN npm install -g @modelcontextprotocol/server-puppeteer
CMD ["npx", "@modelcontextprotocol/server-puppeteer"]
EXPOSE 4000