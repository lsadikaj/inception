
FROM debian:bookworm

RUN apt-get update && apt-get install - y \
	php-fpm \
	php-mysql \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-zip \
	php-intl \
	curl \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /user/local/bin/wp \
	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod -x /user/local/bin/wp

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod -x /entrypoint.sh

CMD ["/entrypoint.sh"]
