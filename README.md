# OpenClaw + AgentGateway Docker Demo

A Docker Compose stack that runs [OpenClaw](https://github.com/openclaw/openclaw) with [AgentGateway](https://agentgateway.dev) as the LLM proxy, plus a full observability layer (Jaeger, Prometheus, Grafana).

## Architecture

```
                                ┌──────────────┐
                                │   OpenAI API  │
                                └──────▲───────┘
                                       │
┌──────────┐   HTTP    ┌──────────────────────────┐   OTLP    ┌────────┐
│ OpenClaw ├──────────►│     AgentGateway          ├──────────►│ Jaeger │
│ :18789   │           │ :3000 (API) :15000 (UI)   │           │ :16686 │
└──────────┘           └──────────┬───────────────┘           └────────┘
                                  │ metrics :15020
                                  ▼
                           ┌─────────────┐      ┌─────────┐
                           │ Prometheus  ├─────►│ Grafana │
                           │ :9090       │      │ :3001   │
                           └─────────────┘      └─────────┘
```

## Prerequisites

- Docker and Docker Compose
- An OpenAI API key

## Quick Start

```bash
# 1. Clone and enter the repo
git clone <this-repo>
cd docker-env-openclaw-agentgateway

# 2. Create your .env file
cp .env.example .env
# Edit .env and set your OPENAI_API_KEY

# 3. Run the setup script
./setup.sh
```

Or manually:

```bash
cp .env.example .env
# edit .env ...
docker compose up -d --build
```

## Services

| Service | URL | Description |
|---------|-----|-------------|
| **OpenClaw** | http://localhost:18789 | AI assistant web UI |
| **AgentGateway API** | http://localhost:3000 | OpenAI-compatible LLM proxy |
| **AgentGateway Admin** | http://localhost:15000/ui/ | Gateway admin dashboard |
| **Jaeger** | http://localhost:16686 | Distributed tracing UI |
| **Prometheus** | http://localhost:9090 | Metrics explorer |
| **Grafana** | http://localhost:3001 | Dashboards (login: admin / admin) |

## Testing AgentGateway Directly

Send a chat completion through AgentGateway:

```bash
curl http://localhost:3000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4.1-nano",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

After making requests, check:
- **Traces** in Jaeger at http://localhost:16686
- **Metrics** in Grafana at http://localhost:3001 (pre-loaded AgentGateway dashboard)
- **Raw metrics** at http://localhost:15020/metrics

## OpenClaw Configuration

OpenClaw is pre-configured to route all OpenAI API calls through AgentGateway. The config lives at `openclaw/openclaw.json`:

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "openai": {
        "baseUrl": "http://agentgateway:3000/v1",
        "models": []
      }
    }
  }
}
```

To run the interactive onboarding wizard (configure messaging channels, etc.):

```bash
docker compose exec openclaw openclaw onboard
```

To change settings after onboarding:

```bash
docker compose exec openclaw openclaw config wizard
```

## AgentGateway Configuration

The gateway config is in `agentgateway/config.yaml`. It currently routes to OpenAI with tracing enabled. You can add more providers (Anthropic, Gemini, etc.) by adding routes — see the [LLM Gateway tutorial](https://agentgateway.dev/docs/local/latest/tutorials/llm-gateway/).

Example multi-provider config with header-based routing:

```yaml
binds:
- port: 3000
  listeners:
  - routes:
    - name: anthropic
      matches:
      - headers:
        - name: x-provider
          value:
            exact: anthropic
      backends:
      - ai:
          name: anthropic
          provider:
            anthropic:
              model: claude-sonnet-4-20250514
      policies:
        backendAuth:
          key: "$ANTHROPIC_API_KEY"

    - name: openai-default
      backends:
      - ai:
          name: openai
          provider:
            openAI:
              model: gpt-4.1-nano
      policies:
        backendAuth:
          key: "$OPENAI_API_KEY"
```

## Stopping

```bash
docker compose down
```

To also remove persisted data (volumes):

```bash
docker compose down -v
```
