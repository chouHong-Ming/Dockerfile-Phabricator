FROM centos:7.7.1908


RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y nginx


ADD asset/phabricator.conf /etc/nginx/conf.d/.


ADD asset/nginx-entrypoint.sh .
ENTRYPOINT ["sh", "nginx-entrypoint.sh"]

