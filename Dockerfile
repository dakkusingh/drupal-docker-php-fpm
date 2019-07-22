FROM drupal:8-fpm-alpine

ENV DRUSH_LAUNCHER_VER="0.6.0" \
    APP_ROOT="/var/www/html"

RUN apk add --update --no-cache \
    bash \
    git \
    nano \
    wget

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Robo CI.
RUN wget https://robo.li/robo.phar && chmod +x robo.phar && mv robo.phar /usr/local/bin/robo

RUN set -ex; \
    # Install Drush
    composer global require drush/drush:^8.0; \
    \
    # Drush launcher
    drush_launcher_url="https://github.com/drush-ops/drush-launcher/releases/download/${DRUSH_LAUNCHER_VER}/drush.phar"; \
    wget -O drush.phar "${drush_launcher_url}"; \
    chmod +x drush.phar; \
    mv drush.phar /usr/local/bin/drush; \
    \
    # We need to remove the contents of /var/www/html folder that is inherited from docker/drupal
    # see https://github.com/docker-library/drupal/blob/master/8.7/fpm-alpine/Dockerfile#L57-L61
    # and prepare the folder for our own code to be fetched by GIT or volume mount.
    rm -rf "${APP_ROOT}";

WORKDIR $APP_ROOT

CMD ["php-fpm"]