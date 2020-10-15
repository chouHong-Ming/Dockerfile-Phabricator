FROM centos:7.7.1908


RUN yum update -y && \
    yum install -y epel-release

RUN yum install -y wget && \
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    rpm -Uvh epel-release-latest-7.noarch.rpm && \
    rpm -Uvh remi-release-7.rpm && \
    rm -f epel-release-latest-7.noarch.rpm remi-release-7.rpm && \
    yum remove -y wget

RUN yum install -y yum-utils python-pip && \
    yum-config-manager --enable remi-php72 && \
    yum install -y php php-mysqlnd php-pdo php-xml php-pear php-devel php-mbstring re2c gcc-c++ gcc make && \
    yum install -y php-fpm php-curl php-xml php-mcrypt php-gd php-mysql php-zip php-apcu php-opcache && \
    pip install --upgrade pip && \
    pip install Pygments && \
    yum remove -y yum-utils python-pip

RUN yum install -y git && \
    cd /var/www/html/ && \
    git clone https://github.com/phacility/libphutil.git && \
    git clone https://github.com/phacility/arcanist.git && \
    git clone https://github.com/phacility/phabricator.git


ADD asset/mailers.json /var/www/html/phabricator/.
RUN mkdir /var/www/html/phabricator/webroot/upload && \
    chown apache:apache /var/www/html/phabricator/webroot/upload

RUN sed -i -e “s/post_max_size\ =\ 8M/post_max_size\ =\ 4096M/g” /etc/php.ini && \
    echo “” >> /etc/php.ini && \
    echo “[OPcache]” >> /etc/php.ini && \
    echo “opcache.validate_timestamps = 1” >> /etc/php.ini && \
    echo “opcache.revalidate_freq = 0” >> /etc/php.ini
RUN mkdir /run/php-fpm/


ADD asset/phabricator-entrypoint.sh .
ENTRYPOINT ["sh", "phabricator-entrypoint.sh"]

