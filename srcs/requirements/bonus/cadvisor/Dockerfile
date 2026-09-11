FROM debian:bookworm

ARG CADVISOR_VERSION=v0.60.5

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
    && curl -fsSL \
        "https://github.com/google/cadvisor/releases/download/${CADVISOR_VERSION}/cadvisor-${CADVISOR_VERSION}-linux-amd64" \
        -o /usr/local/bin/cadvisor \
    && chmod 755 /usr/local/bin/cadvisor \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8090

ENTRYPOINT ["/usr/local/bin/cadvisor"]

CMD ["--port=8090"]
