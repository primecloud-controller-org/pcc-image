#!/bin/bash 

cd /root/work/PrimeCloud-Controller-${PCC_VERSION}

## install bind
yum -y install bind bind-utils bind-chroot
chkconfig named on


## copy sample config file
cp ${PCC_VERSION}/bind/*.rev /var/named/chroot/etc/named
cp ${PCC_VERSION}/bind/*.zone /var/named/chroot/etc/named
cp ${PCC_VERSION}/bind/named.conf /var/named/chroot/etc

## get root.hint
wget http://www.internic.net/domain/named.root -P /var/named/chroot/etc/named

chown named:named /var/named/chroot/etc/named.conf
chown named:named /var/named/chroot/etc/named
chown named:named /var/named/chroot/etc/named/*


## change startup order 
sed -i -e "s/# chkconfig: - 13 87/# chkconfig: - 25 87/g" /etc/init.d/named

## next step 
echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
cp tools/config.sh.sample tools/config.sh


