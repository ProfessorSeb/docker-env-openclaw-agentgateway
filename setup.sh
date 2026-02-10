#!/bin/bash
set -e

echo "=== OpenClaw + AgentGateway Demo Setup ==="
echo ""

# --------------------------------------------------
# 1. Ensure .env exists
# --------------------------------------------------
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from .env.example."
    echo "Edit .env and set your OPENAI_API_KEY, then re-run this script."
    exit 1
fi

source .env

if [ -z "$OPENAI_API_KEY" ] || [ "$OPENAI_API_KEY" = "sk-your-key-here" ]; then
    echo "ERROR: Set a real OPENAI_API_KEY in .env first."
    exit 1
fi

# --------------------------------------------------
# 2. Start the full stack
# --------------------------------------------------
echo "Starting all services..."
docker compose up -d --build

echo ""
echo "Waiting for services to become healthy..."
sleep 8

# --------------------------------------------------
# 3. Verify AgentGateway is up
# --------------------------------------------------
echo ""
echo "Testing AgentGateway endpoint..."
if curl -sf http://localhost:3000/v1/models > /dev/null 2>&1; then
    echo "  AgentGateway is responding."
else
    echo "  AgentGateway not ready yet — give it a few more seconds and try:"
    echo "    curl http://localhost:3000/v1/models"
fi

# --------------------------------------------------
# 4. Print access info
# --------------------------------------------------
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Services:"
echo "  OpenClaw Gateway:    http://localhost:18789"
echo "  AgentGateway Admin:  http://localhost:15000/ui/"
echo "  Jaeger Tracing:      http://localhost:16686"
echo "  Prometheus:          http://localhost:9090"
echo "  Grafana Dashboards:  http://localhost:3001  (admin / ${GRAFANA_PASSWORD:-admin})"
echo ""
echo "Quick test — send a chat completion through AgentGateway:"
echo '  curl http://localhost:3000/v1/chat/completions \'
echo '    -H "Content-Type: application/json" \'
echo '    -d '"'"'{"model":"gpt-4.1-nano","messages":[{"role":"user","content":"Hello!"}]}'"'"
echo ""
echo "OpenClaw onboarding (optional — run once to configure channels):"
echo "  docker compose exec openclaw openclaw onboard"
echo ""
