#!/bin/bash


mkdir /var/www/html/phabricator/webroot/upload
chown apache:apache /var/www/html/phabricator/webroot/upload
chown apache:apache /var/repo/
cd /var/www/html/phabricator/
./bin/config set mysql.host $MYSQL_HOST
./bin/config set mysql.port $MYSQL_PORT
./bin/config set mysql.user $MYSQL_USER
./bin/config set mysql.pass $MYSQL_PASS
./bin/config set phabricator.base-uri 'http://'$HOST_NAME
./bin/config set security.alternate-file-domain http://$HOST_NAME
./bin/config set phabricator.timezone $TIMEZONE
./bin/config set environment.append-paths ‘["/usr/bin","/usr/local/bin","/usr/libexec/git-core"]’
./bin/config set pygments.enabled true
./bin/config set phabricator.developer-mode true
./bin/config set storage.local-disk.path /var/www/html/phabricator/webroot/upload
./bin/config set diffusion.allow-http-auth true
./bin/config set --stdin cluster.mailers < mailers.json
./bin/storage upgrade --force


sed -i -e “s/post_max_size\ =\ 8M/post_max_size\ =\ 4096M/g” /etc/php.ini
echo “” >> /etc/php.ini
echo “[OPcache]” >> /etc/php.ini
echo “opcache.validate_timestamps = 1” >> /etc/php.ini
echo “opcache.revalidate_freq = 0” >> /etc/php.ini
mkdir /run/php-fpm/


./bin/phd start
php-fpm

