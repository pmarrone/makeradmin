PHP_VER_PATH=${MAKERADMIN_PHP_VERSION:-7.2}

#-----------------------

function redeploy_js() {
   local tmp=/var/tmp

   cp /opt/frontend/webpack.config.js /opt/frontend/package.json ${tmp}/data/
   cp -r /opt/frontend/src/                                      ${tmp}/data/

   node ${tmp}/data/node_modules/webpack/bin/webpack.js --config ${tmp}/data/webpack.config.js --progress

   mkdir -p /var/www/html/js/
   mv -f ${tmp}/data/dist/js/app.js /var/www/html/js/
}

#------------------------

function redeploy_apigateway() {
   rm -rf /var/www/html/apigateway
   mkdir -p  /var/www/html/apigateway

   cp -r /opt/apigateway/lumen/*  /var/www/html/apigateway

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

   cp -r /opt/library/lumen/*             /var/www/html/library
   cp -r /opt/library/src/Makeradmin/*    /var/www/html/library
}

#------------------------

function redeploy_frontend() {
   redeploy_js
   cp -r /opt/frontend/dist/* /var/www/html
}

#------------------------

function redeploy_ngix_fpm() {
   servers_stop

   # Servers configuration files
   rm -f /etc/php/${PHP_VER_PATH}/fpm/pool.d/*
   cp /opt/compact/fpm-pool*.conf  /etc/php/${PHP_VER_PATH}/fpm/pool.d
   cp /opt/compact/fpm-php.conf    /etc/php/${PHP_VER_PATH}/php-fpm.conf # fix name

   rm -f /etc/nginx/sites-enabled/*
   rm -f /etc/nginx/nginx.conf
   cp /opt/compact/nginx-*.conf    /etc/nginx/sites-enabled/
   cp /opt/compact/nginx.conf      /etc/nginx/nginx.conf

   chown -R www-data:www-data /var/www/html/*
}


#------------------------

function servers_start() {
   # Start processes
   /usr/sbin/nginx &
   /usr/sbin/php-fpm &

}

function servers_initonce() {
   sleep 2

   # Service init
   /usr/bin/php /var/www/html/apigateway/artisan db:init
   /usr/bin/php /var/www/html/membership/artisan service:register
}

#------------------------

function servers_stop() {
   if [ -r /run/nginx.pid ]; then
       /usr/sbin/nginx -s stop
   fi

   if [ -r /var/run/php/php${PHP_VER_PATH}-fpm.pid ]; then
      kill -QUIT `cat /var/run/php/php${PHP_VER_PATH}-fpm.pid`
   fi
}


