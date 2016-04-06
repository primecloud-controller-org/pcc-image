#!/bin/bash

#yum install
yum -y install expect

hostname pcc01.dev.primecloud-controller.org
sed -i -e "s/HOSTNAME=.*/HOSTNAME=pcc01.dev.primecloud-controller.org/g" /etc/sysconfig/network


#update bind setting
sed -i -e "s/192\.168\.1\.0\/24/172\.31\.0\.0\/16/g" /var/named/chroot/etc/named.conf
sed -i -e "s/#primecloud\.jp/#dev\.primecloud-controller\.org/g" /var/named/chroot/etc/named.conf
sed -i -e "s/primecloud\.jp/dev\.primecloud-controller\.org/g" /var/named/chroot/etc/named.conf
sed -i -e "s/1\.168\.192\.in-addr.arpa/31\.172\.in-addr\.arpa/g" /var/named/chroot/etc/named.conf

sed -i -e "s/primecloud.jp/dev.primecloud-controller.org/g" /var/named/chroot/etc/named/localhost.rev
sed -i -e "s/pcc/pcc01/g" /var/named/chroot/etc/named/localhost.rev

sed -i -e "s/primecloud.jp/dev.primecloud-controller.org/g" /var/named/chroot/etc/named/primecloud.jp.zone
sed -i -e "s/pcc/pcc01/g" /var/named/chroot/etc/named/primecloud.jp.zone

sed -i -e "s/primecloud.jp/dev.primecloud-controller.org/g" /var/named/chroot/etc/named/primecloud.jp.local.rev
sed -i -e "s/pcc/pcc01/g" /var/named/chroot/etc/named/primecloud.jp.local.rev

sed -i -e "s/primecloud.jp/dev.primecloud-controller.org/g" /var/named/chroot/etc/named/primecloud.jp.vpn.rev
sed -i -e "s/pcc/pcc01/g" /var/named/chroot/etc/named/primecloud.jp.vpn.rev


mv /var/named/chroot/etc/named/primecloud.jp.zone /var/named/chroot/etc/named/dev.primecloud-controller.org.zone
mv /var/named/chroot/etc/named/primecloud.jp.local.rev /var/named/chroot/etc/named/dev.primecloud-controller.org.local.rev
mv /var/named/chroot/etc/named/primecloud.jp.vpn.rev /var/named/chroot/etc/named/dev.primecloud-controller.org.vpn.rev


sed -i -e "s/DOMAIN_NAME=\"primecloud\.jp\"/DOMAIN_NAME=\"dev\.primecloud-controller\.org\"/g" /root/work/PrimeCloud-Controller-${PCC_VERSION}/tools/config.sh

#download modify script
#wget http://pcc-bin-bucket.s3.amazonaws.com/modify-default-setting-ver${PCC_VERSION}.zip -P /root/work
wget ${MODIFY_SCRIPT_URL} -P /root/work
unzip /root/work/modify-default-setting-ver${PCC_VERSION}.zip -d /root/work

echo "search dev.primecloud-controller.org" > /etc/resolv.conf
echo "nameserver 127.0.0.1" >>  /etc/resolv.conf



