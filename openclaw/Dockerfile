FROM ghcr.io/openclaw/openclaw:latest

USER root

# Pre-create the config directory with correct ownership so the
# Docker volume mount inherits the right permissions on first run.
RUN mkdir -p /home/node/.openclaw && chown node:node /home/node/.openclaw

COPY openclaw.json /tmp/seed-config.json
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER node

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["node", "dist/index.js"]
