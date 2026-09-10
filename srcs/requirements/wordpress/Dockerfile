FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        php8.2-cli \
        php8.2-curl \
        php8.2-fpm \
        php8.2-gd \
        php8.2-mbstring \
        php8.2-mysql \
        php8.2-xml \
        php8.2-zip \
        php8.2-redis \
        unzip \
    && rm -rf /var/lib/apt/lists/*
	
RUN curl -fsSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp \
    && chmod 755 /usr/local/bin/wp
	
RUN mkdir -p /usr/src/wordpress \
    && wp core download \
        --allow-root \
        --path=/usr/src/wordpress \
        --version=7.1
        
RUN curl -fsSL \
        https://downloads.wordpress.org/plugin/redis-cache.2.8.0.zip \
        -o /tmp/redis-cache.zip \
    && unzip -q /tmp/redis-cache.zip \
        -d /usr/src/wordpress/wp-content/plugins \
    && rm -f /tmp/redis-cache.zip
		
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod 755 /usr/local/bin/wordpress-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
