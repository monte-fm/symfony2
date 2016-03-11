#!/bin/bash
service php5-fpm start
service nginx start
service ssh start
service mysql start

shell /root/etckeeper.sh
rm /root/etckeeper.sh

echo "
#!/bin/bash
service php5-fpm start
service nginx start
service ssh start
service mysql start
" > /root/autostart.sh