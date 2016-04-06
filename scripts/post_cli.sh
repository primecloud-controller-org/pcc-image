#!/bin/bash -x

# set up cli tools
touch /opt/adc/management-tool/logs/info.log
chown tomcat:tomcat /opt/adc/management-tool/logs/info.log

echo "export PATH=\$PATH:/opt/adc/auto-cli/bin" >> ~/.bash_profile


# default pcc user test
source ~/.bash_profile
cd /opt/adc/management-tool-${PCC_VERSION}/bin
./pcc-add-user.sh -u test -p test

/opt/adc/auto-cli/bin/pccadmin add platform --iaasName aws \
	--platformName aws_vpc_tokyo \
	--platformNameDisp 'Amazon EC2 VPC(Tokyo)' \
	--platformSimpleDisp 'Amazon EC2 VPC(Tokyo)' \
	--internal 1 \
	--endpoint https://ap-northeast-1.amazonaws.com \
	--region NORTHEAST


/opt/adc/auto-cli/bin/pccrepo install --moduleName pcc-im_aws_CentOS6.5
/opt/adc/auto-cli/bin/pccadmin add image   --moduleName pcc-im_aws_CentOS6.5 --platformList aws_vpc_tokyo

