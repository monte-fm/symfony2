FROM      ubuntu
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#install PHP
RUN apt-get update -y
RUN apt-get install -y git git-core vim nano mc nginx screen curl unzip
RUN apt-get install -y wget php5 php5-cli php5-common php5-intl 
RUN apt-get install -y php5-json php5-mysql php5-gd php5-imagick
RUN apt-get install -y php5-curl php5-mcrypt php5-dev php5-xdebug
RUN sudo rm /etc/php5/fpm/php.ini
COPY configs/php.ini /etc/php5/fpm/php.ini

#MySQL
RUN echo "mysql-server mysql-server/root_password password pass" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password pass" | debconf-set-selections
RUN sudo apt-get  install -y mysql-server mysql-client

# SSH service
RUN sudo apt-get install -y openssh-server openssh-client
RUN sudo mkdir /var/run/sshd
RUN echo 'root:pass' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc

#composer
RUN cd /usr/bin
RUN curl -sS https://getcomposer.org/installer | php

#aliases
RUN alias ll='ls -la'

#open ports
EXPOSE 80 22
