# Use imagem oficial do PHP com Apache
FROM php:8.1-apache

# Instala extensões e dependências
RUN apt-get update && apt-get install -y \
    zip unzip curl libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copia arquivos do projeto para o container
COPY . /var/www/html

# Define a raiz do documento
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Altera config do Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilita o mod_rewrite
RUN a2enmod rewrite

# Instala dependências do PHP via Composer
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader

# Define permissões (opcional, útil se ocorrer erros de permissão)
RUN chown -R www-data:www-data /var/www/html
