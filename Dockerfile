FROM php:8.2-apache

# Install dependencies and PHP extensions for MySQL and PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_mysql pdo_pgsql

# Enable Apache mod_rewrite headers
RUN a2enmod rewrite headers

# Copy the API folder into the Apache document root
COPY api/ /var/www/html/api/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
