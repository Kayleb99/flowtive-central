FROM php:8.2-apache

# Install dependencies and PHP extensions for MySQL and PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql

# Remove any existing MPM configurations to avoid conflicts, then enable mpm_prefork & modules
RUN rm -f /etc/apache2/mods-enabled/mpm_*.load /etc/apache2/mods-enabled/mpm_*.conf \
    && a2enmod mpm_prefork rewrite headers

# Copy the API folder into the Apache document root
COPY api/ /var/www/html/api/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80