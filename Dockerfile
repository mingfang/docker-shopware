FROM ubuntu:16.04
  
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    TERM=ansi
RUN locale-gen en_US en_US.UTF-8
RUN echo "export PS1='\e[1;31m\]\u@\h:\w\\$\[\e[0m\] '" >> /root/.bashrc
RUN apt-get update

# Runit
RUN apt-get install -y runit 
CMD export > /etc/envvars && /usr/sbin/runsvdir-start
RUN echo 'export > /etc/envvars' >> /root/.bashrc

# Utilities
RUN apt-get install -y vim less net-tools inetutils-ping wget curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common jq psmisc

#Apache
RUN apt-get install -y apache2
RUN a2enmod rewrite

#MySql
RUN apt-get install -y mysql-server mysql-client

#PHP
RUN apt-get install -y php libapache2-mod-php php-mcrypt php-mysql php-gd php-curl php-ssh2 php-simplexml php-mbstring php-zip

#Shopware
RUN wget http://releases.s3.shopware.com.s3.amazonaws.com/install_5.2.2_fec9a405e4d6043625058bc5bf3badecd9197333.zip && \
    unzip install*zip -d /var/www/html && \
    chown -R www-data:www-data /var/www/html && \
    rm install*zip
RUN rm /var/www/html/index.html

COPY php.ini /etc/php/7.0/apache2/
COPY 000-default.conf /etc/apache2/sites-enabled/

#Configure MySql
COPY mysql.ddl /
RUN mysqld_safe & mysqladmin --wait=5 ping && \
    mysql < mysql.ddl && \
    mysqladmin shutdown

# Add runit services
COPY sv /etc/service 
ARG BUILD_INFO
LABEL BUILD_INFO=$BUILD_INFO

