FROM node:18-alpine
WORKDIR /app
RUN npm install -g @modelcontextprotocol/servergithub
CMD ["npx", "@modelcontextprotocol/servergithub"]
COPY scripts/acl-guard.sh /usr/local/bin/acl-guard.sh
RUN chmod +x /usr/local/bin/acl-guard.sh
USER mcp
ENV ALLOWED_PATHS=/workspace
ENTRYPOINT ["/usr/local/bin/acl-guard.sh"]
EXPOSE 4000

