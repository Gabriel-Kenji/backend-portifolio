# Usa imagem oficial do PHP com Apache
FROM php:8.1-apache

# Instala extensões e dependências necessárias
RUN apt-get update && apt-get install -y \
    zip unzip curl libzip-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip mbstring curl xml

# Instala o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho
WORKDIR /var/www/html

# Copia todos os arquivos do projeto para dentro do container
COPY . .

# Define a raiz do documento para o Apache (public/)
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Atualiza o VirtualHost para refletir a nova raiz
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilita o mod_rewrite (necessário para Laravel/Lumen)
RUN a2enmod rewrite

# Instala as dependências do projeto
# Se falhar, mostra o conteúdo do erro em vez de encerrar o build (melhor para debug)
RUN composer install --no-dev --optimize-autoloader || (cat composer.lock && exit 1)

# Corrige permissões (ajustável conforme o servidor)
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Exposição da porta padrão do Apache
EXPOSE 80
