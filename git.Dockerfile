FROM node:18-alpine
RUN apk add --no-cache git
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-git
CMD ["npx", "@modelcontextprotocol/server-git", "/repo"]
COPY scripts/acl-guard.sh /usr/local/bin/acl-guard.sh
RUN chmod +x /usr/local/bin/acl-guard.sh
USER mcp
ENV ALLOWED_PATHS=/workspace
ENTRYPOINT ["/usr/local/bin/acl-guard.sh"]
EXPOSE 4000

