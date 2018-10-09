#!/bin/bash
set -e

shutdown_devel() {
        echo "Shutting down develStartupScript"
        kill -QUIT `cat /var/run/nginx.pid`
        kill -QUIT `cat /var/run/php/php7.2-fpm.pid`
        exit 0
}

# Handle shutdown on signal
trap shutdown_devel SIGHUP SIGINT SIGTERM

# Sleep forever (...or at least until the timestamp overflows :)
# Note: We need to have the "& wait" to be able to trap signals while the sleep is running
echo "develStartupScript is now sleeping " ${SERVER_APP}
sleep inf & wait

