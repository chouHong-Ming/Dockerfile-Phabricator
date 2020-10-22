#!/bin/bash


test -z $HOST_NAME && HOST_NAME=test.local

sed -i -e "s/_HOST_NAME_/$HOST_NAME/g" /etc/nginx/conf.d/phabricator.conf 


nginx

