#!/bin/bash 

cd /root/work/PrimeCloud-Controller-${PCC_VERSION}

## epel
rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm

## openvpn
yum -y install lzo pam-devel lzo-devel openssl-devel openvpn
chkconfig openvpn on

## pam_mysql
cp /root/work/PrimeCloud-Controller-${PCC_VERSION}/${PCC_VERSION}/openvpn/etc_pam.d_openvpn /etc/pam.d/openvpn

cp /root/work/PrimeCloud-Controller-${PCC_VERSION}/${PCC_VERSION}/openvpn/server.conf /etc/openvpn/


## copy easy-rsa
wget http://build.openvpn.net/downloads/releases/easy-rsa-2.2.0_master.tar.gz -P ${PCC_VERSION}/openvpn
tar zxf ${PCC_VERSION}/openvpn/easy-rsa-2.2.0_master.tar.gz -C ${PCC_VERSION}/openvpn

## copy script
cp -r ${PCC_VERSION}/openvpn/easy-rsa-2.2.0_master/easy-rsa/2.0 /etc/openvpn/easy-rsa
cp ${PCC_VERSION}/openvpn/loaduserDB.sh /etc/openvpn/
chmod +x /etc/openvpn/loaduserDB.sh


## set vars
sed -i -e "s/export KEY_COUNTRY=.*/export KEY_COUNTRY=\"JP\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_PROVINCE=.*/export KEY_PROVINCE=\"Tokyo\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_CITY=.*/export KEY_CITY=\"Chiyoda-ku\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_ORG=.*/export KEY_ORG=\"PrimeCloud\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_CN=.*/export KEY_CN=\"pcc.primecloud.jp\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_EMAIL=.*/export KEY_EMAIL=\"pcc@primecloud.jp\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_NAME=.*/export KEY_NAME=\"pcc.primecloud.jp\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export KEY_OU=.*/export KEY_OU=\"PCC\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export PKCS11_MODULE_PATH=.*/export PKCS11_MODULE_PATH=\"changeme\"/"  /etc/openvpn/easy-rsa/vars
sed -i -e "s/export PKCS11_PIN=.*/export PKCS11_PIN=\"1234\"/"  /etc/openvpn/easy-rsa/vars


