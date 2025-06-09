FROM postgres:15
ENV POSTGRES_DB=mydb
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
COPY scripts/acl-guard.sh /usr/local/bin/acl-guard.sh
RUN chmod +x /usr/local/bin/acl-guard.sh
USER mcp
ENV ALLOWED_PATHS=/workspace
ENTRYPOINT ["/usr/local/bin/acl-guard.sh"]
EXPOSE 5432

