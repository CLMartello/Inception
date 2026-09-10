FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        adminer \
        php8.2-cli \
        php8.2-mysql \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/adminer/adminer.php /usr/share/adminer/index.php

WORKDIR /usr/share/adminer

EXPOSE 8081

CMD ["php", "-S", "0.0.0.0:8081", "-t", "/usr/share/adminer"]
