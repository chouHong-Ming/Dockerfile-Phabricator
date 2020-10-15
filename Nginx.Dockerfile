FROM centos:7.7.1908


RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y nginx

RUN yum install -y git && \
    cd /var/www/html/ && \
    git clone https://github.com/phacility/phabricator.git &&\
    git remove -y git


ADD asset/phabricator.conf /etc/nginx/conf.d/.
RUN mkdir /var/www/html/phabricator/webroot/upload && \
    chown apache:apache /var/www/html/phabricator/webroot/upload


ADD asset/nginx-entrypoint.sh .
ENTRYPOINT ["sh", "nginx-entrypoint.sh"]

