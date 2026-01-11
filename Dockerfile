FROM php:8.2-fpm

# ---------------------------------------------------
# System dependencies
# ---------------------------------------------------
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    git \
    unzip \
    curl \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# ---------------------------------------------------
# Install Composer
# ---------------------------------------------------
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# ---------------------------------------------------
# Create project directory
# ---------------------------------------------------
WORKDIR /var/www

# Copy project files
COPY . /var/www

# Laravel permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Install Laravel dependencies
RUN composer install --ignore-platform-reqs

# ---------------------------------------------------
# Configure Nginx
# ---------------------------------------------------
RUN rm /etc/nginx/sites-enabled/default
COPY ./deploy/nginx.conf /etc/nginx/sites-available/laravel.conf
RUN ln -s /etc/nginx/sites-available/laravel.conf /etc/nginx/sites-enabled/

# ---------------------------------------------------
# Supervisor (to run php-fpm + nginx)
# ---------------------------------------------------
COPY ./deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
