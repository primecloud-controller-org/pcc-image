#!/bin/bash 


echo ${DOWNLOAD_URL}
echo ${JDK_URL}

#setup start
yum -y install wget zip vim openssh-clients ld-linux.so.2
yum update -y


#set os setting
##set ip forward
#sed -i -e "s/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/g" /etc/sysctl.conf

##selinux
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

## set timezone
echo "ZONE=\"Asia/Tokyo\"" > /etc/sysconfig/clock
echo "UTC=\"false\"" >> /etc/sysconfig/clock
source /etc/sysconfig/clock
cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

## set lang
echo "LANG=\"ja_JP.UTF-8\"" > /etc/sysconfig/i18n


##set hostname
hostname pcc.primecloud.jp
echo "HOSTNAME=pcc.primecloud.jp" >> /etc/sysconfig/network


#download repository data and packages
mkdir -p /root/work

## for pcc
wget ${DOWNLOAD_URL} -O /root/work/PrimeCloud-Controller-${PCC_VERSION}.tar.gz
tar zxf /root/work/PrimeCloud-Controller-${PCC_VERSION}.tar.gz -C /root/work
cd /root/work/PrimeCloud-Controller-${PCC_VERSION}

## for puppet
rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm

## for python
wget http://legacy.python.org/ftp//python/2.7.2/Python-2.7.2.tgz -P ${PCC_VERSION}/python/
wget http://archive.apache.org/dist/tomcat/tomcat-6/v6.0.37/bin/apache-tomcat-6.0.37.tar.gz -P ${PCC_VERSION}/tomcat6/

## for zabbix
rpm -ivh http://repo.zabbix.jp/relatedpkgs/rhel6/x86_64/zabbix-jp-release-6-6.noarch.rpm
alternatives --display zabbix-jp-release

## download JDK
wget ${JDK_URL} -O ${PCC_VERSION}/java/jdk-6u45-linux-x64-rpm.bin

### pam_mysql
rpm -ivh https://raw.github.com/scsk-oss/library/master/rpm/x86_64/pam_mysql-0.7-0.12.rc1.el6.x86_64.rpm

