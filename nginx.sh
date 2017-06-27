#!/bin/bash
# `/sbin/setuser collectd` runs the given command as the user `collectd`.
# If you omit that part, the command will be run as root.

# Install Network Weathermap
HTMLDIR='/var/www/'
WEATHERMAP="$HTMLDIR/weathermap"
C='*/5 *     * * *   root    /var/www/weathermap/map-poller.php >> /dev/null 2>&1'

if [ ! -d "$WEATHERMAP" ]; then
    cd $HTMLDIR
    wget https://github.com/howardjones/network-weathermap/releases/download/version-0.98/php-weathermap-0.98.zip
 	unzip php-weathermap-0.98.zip
    chown -R nobody:users $WEATHERMAP
    sed -i 's/^\$ENABLED=false;/\$ENABLED=true;/g' $WEATHERMAP/editor.php
    mv /var/www/map-poller.php /var/www/weathermap/
    cd weathermap/lib/datasources
    wget https://raw.githubusercontent.com/guequierre/php-weathermap-influxdb/master/WeatherMapDataSource_influxdb.php
fi

cd

# Check for config directory
if [ ! -d /config ]; then
	mkdir -p /config
fi

# Copy default config if config empty
if [ ! -d  /config/configs ]; then
	mkdir -p /config/configs
fi

if [ ! "$(ls -A /config/configs/)" ]; then
	cp -rf /var/www/weathermap/configs/* /config/configs/
fi

rm -rf /var/www/weathermap/configs
ln -s /config/configs/ /var/www/weathermap/configs
chmod -R 777 /config/configs/

# Check for logs directory
if [ ! -d /config/logs ]; then
	mkdir -p /config/logs
fi

rm -rf /var/log/nginx
ln -s /config/logs/ /var/log/nginx

rm -rf /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/network-weathermap /etc/nginx/sites-enabled/

# Regardless, schedule map-poller.php
echo "$C" > /etc/cron.d/weathermap
/etc/init.d/cron start
/etc/init.d/php7.0-fpm start

exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "daemon off;"