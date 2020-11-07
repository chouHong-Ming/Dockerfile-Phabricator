FROM centos:7.7.1908


RUN yum update -y && \
    yum install -y epel-release which

RUN yum install -y nginx

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

RUN yum install -y openssh openssh-server && \
    yum install -y sudo

RUN yum install -y git && \
    mkdir -p /var/www/html/ && \
    cd /var/www/html/ && \
    git clone https://github.com/phacility/libphutil.git && \
    git clone https://github.com/phacility/arcanist.git && \
    git clone https://github.com/phacility/phabricator.git


RUN sed -i -e "1i daemon off;" /etc/nginx/nginx.conf
ADD asset/phabricator.conf /etc/nginx/conf.d/.


RUN adduser git && \
    usermod -p NP git && \
    echo "git ALL=(root) SETENV: NOPASSWD: /usr/bin/git, /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/ssh, /usr/libexec/git-core/git-http-backend" >> /etc/sudoers

RUN cp /var/www/html/phabricator/resources/sshd/phabricator-ssh-hook.sh /usr/lib/ && \
    sed -i -e "s/vcs-user/git/g" /usr/lib/phabricator-ssh-hook.sh && \
    sed -i -e "s;/path/to/phabricator;/var/www/html/phabricator;g" /usr/lib/phabricator-ssh-hook.sh && \
    chmod 755 /usr/lib/phabricator-ssh-hook.sh

RUN cp /var/www/html/phabricator/resources/sshd/sshd_config.phabricator.example /etc/ssh/sshd_config.phabricator && \
    sed -i -e "s/2222/22/g" /etc/ssh/sshd_config.phabricator && \
    sed -i -e "s/vcs-user/git/g" /etc/ssh/sshd_config.phabricator && \
    sed -i -e "s;/usr/libexec/phabricator-ssh-hook.sh;/usr/lib/phabricator-ssh-hook.sh;g" /etc/ssh/sshd_config.phabricator


ADD asset/mailers.json /var/www/html/phabricator/.
RUN mkdir -p /var/www/html/phabricator/webroot/upload && \
    mkdir -p /var/repo/

RUN echo "apache ALL=(root) SETENV: NOPASSWD: /usr/bin/git, /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/ssh, /usr/libexec/git-core/git-http-backend, /var/www/html/phabricator/phabricator/support/bin/git-http-backend" >> /etc/sudoers  && \
    sed -i -e "s/post_max_size\ =\ 8M/post_max_size\ =\ 4096M/g" /etc/php.ini && \
    echo "" >> /etc/php.ini && \
    echo "[OPcache]" >> /etc/php.ini && \
    echo "opcache.validate_timestamps = 1" >> /etc/php.ini && \
    echo "opcache.revalidate_freq = 0" >> /etc/php.ini
RUN sed -i -e "s/127\.0\.0\.1\:9000/0\.0\.0\.0\:9000/g" /etc/php-fpm.d/www.conf
RUN mkdir /run/php-fpm/


ADD asset/entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]

