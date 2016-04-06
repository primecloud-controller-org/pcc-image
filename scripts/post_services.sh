#!/bin/bash -x

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



