FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y curl ca-certificates git jq && \
    rm -rf /var/lib/apt/lists/*

# Install agentgateway binary via official script
RUN curl -L https://raw.githubusercontent.com/agentgateway/agentgateway/refs/heads/main/common/scripts/get-agentgateway | bash

RUN mkdir -p /etc/agentgateway

COPY config.yaml /etc/agentgateway/config.yaml

EXPOSE 3000 15000 15020

WORKDIR /etc/agentgateway

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=10s \
  CMD curl -f http://localhost:3000/health || exit 1

CMD ["/usr/local/bin/agentgateway", "-f", "/etc/agentgateway/config.yaml"]
