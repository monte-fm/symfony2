FROM      ubuntu
MAINTAINER Olexander Kutsenko <olexander.kutsenko@gmail.com>

#Create docker user
RUN mkdir -p /home/docker
RUN useradd -d /home/docker -s /bin/bash -M -N -G www-data,sudo docker
RUN chown -R docker:www-data /home/docker
RUN echo docker:docker | chpasswd

#install PHP
RUN apt-get update -y
RUN apt-get install -y software-properties-common python-software-properties
RUN apt-get install -y git git-core vim nano mc nginx screen curl unzip
RUN apt-get install -y wget php5 php5-fpm php5-cli php5-common php5-intl 
RUN apt-get install -y php5-json php5-mysql php5-gd php5-imagick
RUN apt-get install -y php5-curl php5-mcrypt php5-dev php5-xdebug
RUN sudo rm /etc/php5/fpm/php.ini
COPY configs/php.ini /etc/php5/fpm/php.ini
COPY configs/nginx/default /etc/nginx/sites-available/default

#MySQL install + password
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN sudo apt-get  install -y mysql-server mysql-client

# SSH service
RUN sudo apt-get install -y openssh-server openssh-client
RUN sudo mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
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

#ant install
RUN sudo apt-get install -y default-jre default-jdk
RUN sudo apt-get install -y ant

#Composer
RUN cd /home
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN chmod 777 /usr/local/bin/composer

#Code standart
RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "sebastian/phpcpd=*"
RUN composer global require "phpmd/phpmd=@stable"
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcpd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpmd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcs

#Add colorful command line
RUN echo "force_color_prompt=yes" >> .bashrc
RUN echo "export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> .bashrc

#Autocomplete symfony2

COPY configs/files/symfony2-autocomplete.bash /etc/bash_completion.d/
RUN echo "if [ -e /etc/bash_completion.d/symfony2-autocomplete.bash ]; then \
	. /etc/bash_completion.d/symfony2-autocomplete.bash \
    fi" >> /etc/bash.bashrc

#etcKeeper
RUN mkdir -p /root/etckeeper
COPY configs/etckeeper.sh /root
COPY configs/files/etckeeper-hook.sh /root/etckeeper
RUN /root/etckeeper.sh

#Xdebug
RUN echo "zend_extension=/usr/lib/php5/20121212/xdebug.so \
    xdebug.default_enable = 1 \
    xdebug.idekey = PHPSTORM \
    xdebug.remote_enable = 1 \
    xdebug.remote_autostart = 1 \
    xdebug.remote_port = 9000 \
    xdebug.remote_handler=dbgp \
    xdebug.remote_log=/var/log/xdebug/xdebug.log \
    xdebug.remote_connect_back=1 \
    xdebug.max_nesting_level=250 \
    xdebug.remote_host = localhost" > /etc/php5/mods-available/xdebug.ini
RUN echo "export PHP_IDE_CONFIG=\"serverName=localhost\"" >> ~/.bashrc
RUN echo "export PHP_IDE_CONFIG=\"serverName=localhost\"" >> /home/docker/.bashrc


#open ports
EXPOSE 80 22 9000
