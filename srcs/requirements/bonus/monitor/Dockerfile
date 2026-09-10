FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
    && rm -rf /var/lib/apt/lists/*

COPY app/server.py /usr/local/bin/monitor-server.py

RUN chmod 755 /usr/local/bin/monitor-server.py

EXPOSE 8090

CMD ["python3", "/usr/local/bin/monitor-server.py"]
