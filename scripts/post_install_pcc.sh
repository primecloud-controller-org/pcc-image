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


# Update zabbox setting
sed -i -e "s/zabbix.server = <IPaddress>/zabbix.server = localhost/g" /opt/adc/conf/config.properties
sed -i -e "s/zabbix.url = http:\/\/<IPaddress>\/zabbix\//zabbix.url = http:\/\/localhost\/zabbix\//g" /opt/adc/conf/config.properties

sed -i -e "s/\/var\/lock\/subsys\/zabbix/\/var\/lock\/subsys\/zabbix-server/g" /etc/init.d/zabbix-server
sed -i -e "s/DBUser=root/DBUser=zabbix/g" /etc/zabbix/zabbix_server.conf
sed -i -e "s/# DBPassword=/# DBPassword=\n\nDBPassword=password/g" /etc/zabbix/zabbix_server.conf

cat > /etc/zabbix/zabbix.conf.php <<ZABBIX_CONF
<?php
// Zabbix GUI configuration file
global $DB;

$DB["TYPE"]                             = 'MYSQL';
$DB["SERVER"]                   = 'localhost';
$DB["PORT"]                             = '0';
$DB["DATABASE"]                 = 'zabbix';
$DB["USER"]                             = 'zabbix';
$DB["PASSWORD"]                 = 'password';
// SCHEMA is relevant only for IBM_DB2 database
$DB["SCHEMA"]                   = '';

$ZBX_SERVER                             = 'localhost';
$ZBX_SERVER_PORT                = '10051';
$ZBX_SERVER_NAME                = '';

$IMAGE_FORMAT_DEFAULT   = IMAGE_FORMAT_PNG;
?>
ZABBIX_CONF

chown apache:apache /etc/zabbix/zabbix.conf.php
chmod 400 /etc/zabbix/zabbix.conf.php


# add api user
## default password: password
cd /root/work/PrimeCloud-Controller-2.4.5/tools
source /root/work/PrimeCloud-Controller-2.4.5/tools/config.sh

mysql -u${ZABBIX_DATABASE_USER} -p${ZABBIX_DATABASE_PASS} zabbix -e "INSERT INTO users VALUES (3,'api','api access user','api','5f4dcc3b5aa765d61d8327deb882cf99','',0,0,'en_gb',30,3,'default.css',0,'',50);"
mysql -u${ZABBIX_DATABASE_USER} -p${ZABBIX_DATABASE_PASS} zabbix -e "INSERT INTO users_groups VALUES (3,10,3);"

# set up cli tools
touch /opt/adc/management-tool/logs/info.log
chown tomcat:tomcat /opt/adc/management-tool/logs/info.log

echo "export PATH=\$PATH:/opt/adc/auto-cli/bin" >> ~/.bash_profile

# add tomcat service directory

mkdir -p /opt/data/default/tomcat
wget http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz -P /opt/data/default/tomcat
tar zxf /opt/data/default/tomcat/apache-tomcat-6.0.37.tar.gz -C /opt/data/default/tomcat
mkdir -p /opt/data/default/tomcat/apache-tomcat-6.0.37/conf/Catalina/localhost/
ls -al /opt/data/default/tomcat/apache-tomcat-6.0.37

cd /opt/data/default/tomcat/apache-tomcat-6.0.37/bin
tar zxf commons-daemon-native.tar.gz
cd commons-daemon-1.0.15-native-src/unix
./configure && make

cp jsvc /etc/puppet/modules/tomcat/files/



# default pcc user test
source ~/.bash_profile
cd /opt/adc/management-tool-2.4.5/bin
./pcc-add-user.sh -u test -p test

/opt/adc/auto-cli/bin/pcc add platform --iaasName aws \
	--platformName aws_vpc_tokyo \
	--platformNameDisp 'Amazon EC2 VPC(Tokyo)' \
	--platformSimpleDisp 'Amazon EC2 VPC(Tokyo)' \
	--internal 1 \
	--endpoint https://ap-northeast-1.amazonaws.com \
	--region NORTHEAST


/opt/adc/auto-cli/bin/pccrepo install --moduleName pcc-im_aws_CentOS6.5
/opt/adc/auto-cli/bin/pcc add image   --moduleName pcc-im_aws_CentOS6.5 --platformList aws_vpc_tokyo

