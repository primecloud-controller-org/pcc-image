#!/bin/bash

cd /root/work/PrimeCloud-Controller-${PCC_VERSION}/tools
cp config.sh.sample config.sh
sed -i -e "s/PCC_VERSION=.*/PCC_VERSION=${PCC_VERSION}/" config.sh

sed -i -e "s/sudo find/find/g" install.sh
sed -i -e "/echo \"Error: failed nifty image files copy.\"  >>*/,/exit 1/d" install.sh

chmod a+x install.sh
sh ./install.sh

