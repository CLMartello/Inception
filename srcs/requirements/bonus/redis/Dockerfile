FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends redis-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/entrypoint.sh /usr/local/bin/redis-entrypoint.sh

RUN chmod 755 /usr/local/bin/redis-entrypoint.sh

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/redis-entrypoint.sh"]
CMD ["redis-server", "/etc/redis/redis.conf"]
