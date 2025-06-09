FROM node:18-alpine
WORKDIR /app
RUN npm install -g mcp-server-time
CMD ["npx", "mcp-server-time"]
COPY scripts/acl-guard.sh /usr/local/bin/acl-guard.sh
RUN chmod +x /usr/local/bin/acl-guard.sh
USER mcp
ENV ALLOWED_PATHS=/workspace
ENTRYPOINT ["/usr/local/bin/acl-guard.sh"]
EXPOSE 4000

