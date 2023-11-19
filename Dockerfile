FROM ghcr.io/railwayapp/nixpacks:ubuntu-1699920194

ENTRYPOINT ["/bin/bash", "-l", "-c"]
WORKDIR /app/


COPY .nixpacks/nixpkgs-5148520bfab61f99fd25fb9ff7bfbb50dad3c9db.nix .nixpacks/nixpkgs-5148520bfab61f99fd25fb9ff7bfbb50dad3c9db.nix
RUN nix-env -if .nixpacks/nixpkgs-5148520bfab61f99fd25fb9ff7bfbb50dad3c9db.nix && nix-collect-garbage -d

COPY .nixpacks/assets /assets/
ARG IS_LARAVEL NIXPACKS_METADATA NIXPACKS_PHP_ROOT_DIR PORT
ENV IS_LARAVEL=$IS_LARAVEL NIXPACKS_METADATA=$NIXPACKS_METADATA NIXPACKS_PHP_ROOT_DIR=$NIXPACKS_PHP_ROOT_DIR PORT=$PORT

# setup phase
# noop

# install phase
COPY . /app/.
RUN  mkdir -p /var/log/nginx && mkdir -p /var/cache/nginx
#RUN  composer install --ignore-platform-reqs
RUN  composer install
RUN  npm ci

# build phase
COPY . /app/.
RUN  npm run build





# start
COPY . /app
CMD ["node /assets/scripts/prestart.mjs /assets/nginx.template.conf /nginx.conf && (php-fpm -y /assets/php-fpm.conf & nginx -c /nginx.conf)"]

