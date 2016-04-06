#!/bin/bash

touch /root/firstrun

yum clean all

cat /dev/null > /var/log/btmp
cat /dev/null > /var/log/cron
cat /dev/null > /var/log/dmesg
cat /dev/null > /var/log/wtmp
cat /dev/null > /var/log/secure
cat /dev/null > /var/log/lastlog

rm -f /var/log/anaconda.*
rm -f /var/log/boot.log
rm -f /var/log/dmesg.*
rm -f /var/log/dracut.log
rm -f /var/log/maillog
rm -f /var/log/messages
rm -f /var/log/spooler
rm -f /var/log/tallylog
rm -f /var/log/yum.log
rm -f /var/log/audit/audit.log

rm -f  /root/.bash_history
rm -f /root/.bash_logout


cat /dev/null > /root/.ssh/authorized_keys
rm -f /etc/ssh/ssh_host_*

history -c

