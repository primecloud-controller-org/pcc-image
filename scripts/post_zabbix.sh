#!/bin/bash -x

# install mod_ssl
yum -y install mod_ssl
/etc/init.d/httpd restart

# disable services
chkconfig openvpn off
chkconfig named off
chkconfig puppetmaster off
chkconfig httpd off
chkconfig mysqld off
chkconfig zabbix-agent off
chkconfig zabbix-server off
chkconfig tomcat off

cd /root/work/PrimeCloud-Controller-${PCC_VERSION}/tools
source /root/work/PrimeCloud-Controller-${PCC_VERSION}/tools/config.sh

# Update zabbox setting
sed -i -e "s/zabbix.server = <IPaddress>/zabbix.server = localhost/g" /opt/adc/conf/config.properties
sed -i -e "s/zabbix.url = http:\/\/<IPaddress>\/zabbix\//zabbix.url = http:\/\/localhost\/zabbix\//g" /opt/adc/conf/config.properties
sed -i -e "s/\/var\/lock\/subsys\/zabbix/\/var\/lock\/subsys\/zabbix-server/g" /etc/init.d/zabbix-server
sed -i -e "s/DBUser=root/DBUser=zabbix/g" /etc/zabbix/zabbix_server.conf
sed -i -e "s/# DBPassword=/# DBPassword=\n\nDBPassword=password/g" /etc/zabbix/zabbix_server.conf

# create zabbix.conf.php
cat > /etc/zabbix/zabbix.conf.php <<ZABBIX_CONF
<?php
// Zabbix GUI configuration file
global \$DB;

\$DB["TYPE"]                             = 'MYSQL';
\$DB["SERVER"]                   = 'localhost';
\$DB["PORT"]                             = '0';
\$DB["DATABASE"]                 = 'zabbix';
\$DB["USER"]                             = '${ZABBIX_DATABASE_USER}';
\$DB["PASSWORD"]                 = '${ZABBIX_DATABASE_PASS}';
// SCHEMA is relevant only for IBM_DB2 database
\$DB["SCHEMA"]                   = '';

\$ZBX_SERVER                             = 'localhost';
\$ZBX_SERVER_PORT                = '10051';
\$ZBX_SERVER_NAME                = '';

\$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
?>
ZABBIX_CONF

chown apache:apache /etc/zabbix/zabbix.conf.php
chmod 400 /etc/zabbix/zabbix.conf.php

# add api user
## default password: password

mysql -u${ZABBIX_DATABASE_USER} -p${ZABBIX_DATABASE_PASS} zabbix -e "INSERT INTO users VALUES (3,'api','api access user','api','5f4dcc3b5aa765d61d8327deb882cf99','',0,0,'en_gb',30,3,'default.css',0,'',0,50);"
mysql -u${ZABBIX_DATABASE_USER} -p${ZABBIX_DATABASE_PASS} zabbix -e "INSERT INTO users_groups VALUES (3,10,3);"



# import zabbix template
## login
curl -L -k -c /tmp/cookie.txt https://localhost/zabbix/index.php \
-F form_refresh=1 \
-F form=1 \
-F name=admin \
-F password=zabbix \
-F enter=Enter \
| gawk 'match($0, /templates.php\?sid=[[:alnum:]]*/){print substr($0,RSTART+18,16)}' > /tmp/sid.txt

sid=`cat /tmp/sid.txt`

## get 
curl -L -k -b /tmp/cookie.txt https://localhost/zabbix/templates.php \
	-F sid=$sid \
	-F form_refresh=1 \
	-F form=テンプレートのインポート \

## exec import
curl -L -k -b /tmp/cookie.txt https://localhost/zabbix/templates.php \
	-F sid=$sid \
	-F form_refresh=2 \
	-F form=テンプレートのインポート \
	-F import_file=@/root/work/PrimeCloud-Controller-${PCC_VERSION}/${PCC_VERSION}/zabbix/zabbix_export.xml \
	-F rules[host][exist]=yes \
	-F rules[host][missed]=yes \
	-F rules[template][exist]=yes \
	-F rules[item][exist]=yes \
	-F rules[item][missed]=yes \
	-F rules[trigger][exist]=yes \
	-F rules[trigger][missed]=yes \
	-F rules[graph][exist]=yes \
	-F rules[graph][missed]=yes \

