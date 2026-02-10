FROM ghcr.io/openclaw/openclaw:latest

# Copy seed config and entrypoint
USER root
COPY openclaw.json /tmp/seed-config.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["node", "dist/index.js"]
