#!/bin/bash 


#load download url
ls -al /root
sleep 45

source /root/script_info.sh

rm -f /root/script_info.sh


#setup start
yum -y install wget zip vim openssh-clients ld-linux.so.2
yum update -y


#set ip forward
sed -i -e "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf

#selinux
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

# set timezone
echo "ZONE=\"Asia/Tokyo\"" > /etc/sysconfig/clock
echo "UTC=\"false\"" >> /etc/sysconfig/clock
source /etc/sysconfig/clock
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# set lang
echo "LANG=\"ja_JP.UTF-8\"" > /etc/sysconfig/i18n


#set hostname
hostname pcc.primecloud.jp
echo "HOSTNAME=pcc.primecloud.jp" >> /etc/sysconfig/network


#download repository data and packages
mkdir -p /root/work

## for pcc
wget ${DOWNLOAD_URL} -O /root/work/PrimeCloud-Controller-2.4.5.tar.gz
tar zxf /root/work/PrimeCloud-Controller-2.4.5.tar.gz -C /root/work
cd /root/work/PrimeCloud-Controller-2.4.5

## for puppet
rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm

## for python
wget http://legacy.python.org/ftp//python/2.7.2/Python-2.7.2.tgz -P 2.4.5/python/
wget  http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz -P 2.4.5/tomcat6/

## for zabbix
rpm -ivh http://repo.zabbix.jp/relatedpkgs/rhel6/x86_64/zabbix-jp-release-6-6.noarch.rpm
alternatives --display zabbix-jp-release

## download JDK
wget ${JDK_URL} -O 2.4.5/java/jdk-6u45-linux-x64-rpm.bin


## epel
rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

## openvpn
yum -y install lzo pam-devel lzo-devel openssl-devel openvpn
chkconfig openvpn on

### pam_mysql
rpm -ivh https://raw.github.com/scsk-oss/library/master/rpm/x86_64/pam_mysql-0.7-0.12.rc1.el6.x86_64.rpm

cp /root/work/PrimeCloud-Controller-2.4.5/2.4.5/openvpn/server.conf /etc/openvpn/


### easy-rsa
wget http://build.openvpn.net/downloads/releases/easy-rsa-2.2.0_master.tar.gz -P 2.4.5/openvpn
tar zxf 2.4.5/openvpn/easy-rsa-2.2.0_master.tar.gz -C 2.4.5/openvpn

### 
cp -r 2.4.5/openvpn/easy-rsa-2.2.0_master/easy-rsa/2.0 /etc/openvpn/easy-rsa
cp 2.4.5/openvpn/loaduserDB.sh /etc/openvpn/
chmod +x /etc/openvpn/loaduserDB.sh


## bind
yum -y install bind bind-utils bind-chroot
chkconfig named on


cp 2.4.5/bind/*.rev /var/named/chroot/etc/named
cp 2.4.5/bind/*.zone /var/named/chroot/etc/named
cp 2.4.5/bind/named.conf /var/named/chroot/etc

wget http://www.internic.net/domain/named.root -P /var/named/chroot/etc/named

chown named:named /var/named/chroot/etc/named.conf
chown named:named /var/named/chroot/etc/named
chown named:named /var/named/chroot/etc/named/*


sed -i -e "s/# chkconfig: - 13 87/# chkconfig: - 25 87/g" /etc/init.d/named

echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0

cp tools/config.sh.sample tools/config.sh


