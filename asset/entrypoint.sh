#!/bin/bash


test -z $UPSTREAM && UPSTREAM=127.0.0.1

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

test -f /etc/ssh/ssh_host_rsa_key || ssh-keygen -A
test -f /etc/ssh/ssh_host_dsa_key || ssh-keygen -A
test -f /etc/ssh/ssh_host_ecdsa_key || ssh-keygen -A
test -f /etc/ssh/ssh_host_ed25519_key || ssh-keygen -A

sed -i -e "s/_HOST_NAME_/$HOST_NAME/g" /etc/nginx/conf.d/phabricator.conf 
sed -i -e "s/_UPSTREAM_/$UPSTREAM/g" /etc/nginx/conf.d/phabricator.conf 

sed -i -e "s/_MAILERS_KEY_/$MAILERS_KEY/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_HOST_/$MAILERS_HOST/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/\"_MAILERS_PORT_\"/$MAILERS_PORT/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_USER_/$MAILERS_USER/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_PASS_/$MAILERS_PASS/g" /var/www/html/phabricator/mailers.json
sed -i -e "s/_MAILERS_PROT_/$MAILERS_PROT/g" /var/www/html/phabricator/mailers.json


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

