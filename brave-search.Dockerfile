FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/server-brave-search
CMD ["npx", "@modelcontextprotocol/server-brave-search"]
COPY scripts/acl-guard.sh /usr/local/bin/acl-guard.sh
RUN chmod +x /usr/local/bin/acl-guard.sh
USER mcp
ENV ALLOWED_PATHS=/workspace
ENTRYPOINT ["/usr/local/bin/acl-guard.sh"]
EXPOSE 4000
