PHP_VER_PATH=${MAKERADMIN_PHP_VERSION:-7.2}

#-----------------------

function redeploy_frontend() {
   local tmp=/var/tmp/data
   local cdir=`pwd`

   rm -rf ${tmp}
   mkdir -p ${tmp}/dist/js

   cp /opt/frontend/webpack.config.js           ${tmp}/
   cp /opt/frontend/member.webpack.config.js    ${tmp}/
   cp /opt/frontend/package.json                ${tmp}/
   cp /opt/frontend/package-lock.json           ${tmp}/
   cp -r /opt/frontend/src/                     ${tmp}/src/
   cp /opt/frontend/jestSetup.js                ${tmp}/

   cd ${tmp}

   echo -----------------
   npm install

   echo -----------------
   npm run eslint
   npm run test

   echo -----------------
   ./node_modules/.bin/webpack --config ./webpack.config.js

   echo -----------------
   ./node_modules/.bin/webpack --config ./member.webpack.config.js

   cd /

   mkdir -p /var/www/html/js/

   cp -r /opt/frontend/dist/* /var/www/html
   cp -rf ${tmp}/dist/*       /var/www/html

   cd ${cdir}
}

#------------------------

function redeploy_apigateway() {
   mkdir -p  /var/www/html/

   cp -r /opt/apigateway/lumen/*  /var/www/html/

   cp /opt/apigateway/docker/myStartupScript.sh /scripts/apigatewayStartupScript.sh
}

#------------------------

function redeploy_membership() {
   rm -rf /var/www/html/membership
   mkdir -p  /var/www/html/membership

   cp -r /opt/membership/lumen/*          /var/www/html/membership
   ln -s /var/www/html/library            /var/www/html/membership/library
   ln -s /var/www/html/vendor             /var/www/html/membership/vendor

   cp /opt/membership/docker/myStartupScript.sh /scripts/membershipStartupScript.sh
}

#------------------------

function redeploy_library() {
   rm -rf /var/www/library/
   mkdir -p /var/www/html/library/

   cp /opt/library/lumen/composer.json /var/www/html/
   cp /opt/library/lumen/composer.lock /var/www/html/

   composer install --no-scripts --no-autoloader --no-suggest --no-dev -d /var/www/html
   composer dumpautoload --no-dev -d /var/www/html

   cp -r /opt/library/lumen/*             /var/www/html/library
   cp -r /opt/library/src/Makeradmin/*    /var/www/html/library
}

#------------------------

function redeploy_servers_conf() {
   local etcphp=/etc/php/${PHP_VER_PATH}/fpm
   local etcdef=/etc/default/php-fpm${PHP_VER_PATH}

   servers_stop

   mkdir -p /var/log/madm/

   # Php configuration files

   rm -f ${etcphp}/fpm/pool.d/*
   rm -f ${etcphp}/fpm/php.ini
   rm -f ${etcdef}

   cp /opt/compact/fpm/fpm-pool*.conf   ${etcphp}/pool.d/
   cp /opt/compact/fpm/php-fpm.conf     ${etcphp}/php-fpm.conf
   cp /opt/compact/fpm/php.ini          ${etcphp}/

   cp /opt/compact/fpm/php-fpm-initd-vars ${etcdef}

   # Nginx configuration files

   rm -f /etc/nginx/sites-enabled/*
   rm -f /etc/nginx/nginx.conf

   cp /opt/compact/nginx/nginx-*.conf    /etc/nginx/sites-enabled/
   cp /opt/compact/nginx/nginx.conf      /etc/nginx/nginx.conf

   # owner root www folder
   chown -R www-data:www-data /var/www/html/*
}

#------------------------

function servers_initonce() {
   sleep 2

   # log init
   local lpath=/var/log/madm
   mkdir -p ${lpath}
   chgrp www-data ${lpath}
   chmod g+w ${lpath}

   # Service init
   /usr/bin/php /var/www/html/apigateway/artisan db:init
   /usr/bin/php /var/www/html/membership/artisan service:register
}

#------------------------

function servers_start() {
   # Start processes
   /etc/init.d/nginx start
   /etc/init.d/php${PHP_VER_PATH}-fpm start
}

#------------------------

function servers_stop() {
   /etc/init.d/php${PHP_VER_PATH}-fpm stop
   /etc/init.d/nginx stop

  sleep 3

   # Force if not down
   if [ -r /run/nginx.pid ]; then
       /usr/sbin/nginx -s stop
   fi

   if [ -r /var/run/php/php${PHP_VER_PATH}-fpm.pid ]; then
      kill -QUIT `cat /var/run/php/php${PHP_VER_PATH}-fpm.pid`
   fi
}

function servers_restart() {
   servers_stop
   servers_start
}



