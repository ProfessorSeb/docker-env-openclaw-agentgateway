#!/bin/bash
set -e

# Seed the OpenClaw config on first run if it doesn't exist yet.
# On subsequent runs the persisted volume copy is used instead.
if [ ! -f "$HOME/.openclaw/openclaw.json" ]; then
    mkdir -p "$HOME/.openclaw"
    cp /tmp/seed-config.json "$HOME/.openclaw/openclaw.json"
    echo "[entrypoint] Seeded OpenClaw config with AgentGateway settings"
fi

exec "$@"
