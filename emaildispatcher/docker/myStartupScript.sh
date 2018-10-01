#!/bin/bash
set -e

# Wait for api-gateway to be ready
/usr/local/myscripts/wait-for api-gateway:80

# Not sure if these directories are needed, but let's create them anyway
mkdir -p /var/www/html/storage/

# Make sure the webserver have write permissions
chown -R www-data:www-data /var/www/html/storage/

shutdown() {
	echo "Shutting down service"
	php /var/www/html/artisan service:unregister
	kill -QUIT `cat /var/run/nginx.pid`
	kill -QUIT `cat /var/run/php/php7.2-fpm.pid`
	exit 0
}

# Unregister the service when the script is shut down
trap shutdown SIGHUP SIGINT SIGTERM

# Start nginx
echo "Starting server"
php-fpm -R
nginx

# Register the service immediately
php /var/www/html/artisan service:register

# Send out emails, this command does not return.
exec php /var/www/html/artisan service:send
