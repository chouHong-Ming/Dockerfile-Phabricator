#!/bin/bash


test -z $UPSTREAM && UPSTREAM=127.0.0.1
test -z $TRUST_LAYER && TRUST_LAYER=0

test -z $HTTPS_ENABLE && HTTPS_ENABLE=false
test -z $MYSQL_HOST && MYSQL_HOST=127.0.0.1
test -z $MYSQL_PORT && MYSQL_PORT=3306
test -z $MYSQL_USER && MYSQL_USER=phabricator
test -z $MYSQL_PASS && MYSQL_PASS=password
test -z $HOST_NAME && HOST_NAME=test.local
test -z $TIMEZONE && TIMEZONE=UTC
test -z $MAILERS_KEY && MAILERS_KEY=SMTP
test -z $MAILERS_HOST && MAILERS_HOST=127.0.0.1
test -z $MAILERS_PORT && MAILERS_PORT=465
test -z $MAILERS_USER && MAILERS_USER=root
test -z $MAILERS_PASS && MAILERS_PASS=root
test -z $MAILERS_PROT && MAILERS_PROT=SSL


echo "[Info] Set ssh config"
if ! [ -f "/server_key/ssh_host_rsa_key" ] || ! [ -f "/server_key/ssh_host_dsa_key" ] || ! [ -f "/server_key/ssh_host_ecdsa_key" ] || ! [ -f "/server_key/ssh_host_ed25519_key" ]; then
    echo "[Info] Generate ssh key"
    ssh-keygen -A
    sudo cp /etc/ssh/ssh_host_rsa_key* /etc/ssh/ssh_host_dsa_key* /etc/ssh/ssh_host_ecdsa_key* /etc/ssh/ssh_host_ed25519_key* /server_key/.
else
    echo "[Info] Copy exist ssh key"
    sudo cp /server_key/* /etc/ssh/.
fi


sed -i -e "s/_HOST_NAME_/$HOST_NAME/g" /etc/nginx/conf.d/phabricator.conf 
sed -i -e "s/_UPSTREAM_/$UPSTREAM/g" /etc/nginx/conf.d/phabricator.conf 

sed -i -e "s/_MAILERS_KEY_/$MAILERS_KEY/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_HOST_/$MAILERS_HOST/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/\"_MAILERS_PORT_\"/$MAILERS_PORT/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_USER_/$MAILERS_USER/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_PASS_/$MAILERS_PASS/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_PROT_/$MAILERS_PROT/g" /var/www/html/phabricator/mailers.json


if [ $(ls -l /etc/nginx/conf.d/add_conf/ | wc -l) -gt "1" ]; then
    echo "[Info] Import Nginx additional conf for Phabricator"
    sed -i -e "s;#include;include;g" /etc/nginx/conf.d/phabricator.conf
fi


chown apache:apache /var/www/html/phabricator/webroot/upload
chown apache:apache /var/repo/
cd /var/www/html/phabricator/
if [ $TRUST_LAYER == "0" ]; then
    echo "[Info] Disable trust x forearded for header"
elif [ $TRUST_LAYER == "1" ]; then
    echo "[Info] Enable trust 1 layer x forearded for header"
    sed -i -e "s;// preamble_trust_x_forwarded_for_header;preamble_trust_x_forwarded_for_header;g" /var/www/html/phabricator/support/preamble.php
    sed -i -e "s;_TRUST_LAYER_;;g" /var/www/html/phabricator/support/preamble.php
else
    echo "[Info] Enable trust "$TRUST_LAYER" layers x forearded for header"
    sed -i -e "s;// preamble_trust_x_forwarded_for_header;preamble_trust_x_forwarded_for_header;g" /var/www/html/phabricator/support/preamble.php
    sed -i -e "s;_TRUST_LAYER_;$TRUST_LAYER;g" /var/www/html/phabricator/support/preamble.php
fi
./bin/config set mysql.host $MYSQL_HOST
./bin/config set mysql.port $MYSQL_PORT
./bin/config set mysql.user $MYSQL_USER
./bin/config set mysql.pass $MYSQL_PASS
if [ $HTTPS_ENABLE == "true" ]; then
    ./bin/config set phabricator.base-uri 'https://'$HOST_NAME
    ./bin/config set security.alternate-file-domain https://$HOST_NAME
    sed -i -e "s;// \$_SERVER;\$_SERVER;g" /var/www/html/phabricator/support/preamble.php
else
    ./bin/config set phabricator.base-uri 'https://'$HOST_NAME
    ./bin/config set security.alternate-file-domain https://$HOST_NAME
fi
./bin/config set phabricator.timezone $TIMEZONE
./bin/config set environment.append-paths '["/usr/bin","/usr/local/bin","/usr/libexec/git-core"]'
./bin/config set pygments.enabled true
./bin/config set phabricator.developer-mode true
./bin/config set storage.local-disk.path /var/www/html/phabricator/webroot/upload
./bin/config set diffusion.allow-http-auth true
./bin/config set --stdin cluster.mailers < mailers.json
./bin/config set phd.user root
./bin/config set diffusion.ssh-user git
./bin/storage upgrade --force


./bin/phd start
php-fpm &
/usr/sbin/sshd -f /etc/ssh/sshd_config.phabricator
nginx

