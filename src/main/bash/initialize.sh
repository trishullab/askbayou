#!/bin/bash

apt-get update
apt-get install unzip

adduser --gecos '' --disabled-password askbayou

wget http://release.askbayou.com/bayou-1.0.0-ubuntu-16.01.zip

mv bayou-1.0.0-ubuntu-16.01.zip /home/askbayou/bayou-1.0.0-ubuntu-16.01.zip
sudo -u askbayou sh -c "unzip /home/askbayou/bayou-1.0.0-ubuntu-16.01.zip -d /home/askbayou"
sudo -u askbayou sh -c "rm -f /home/askbayou/bayou-1.0.0-ubuntu-16.01.zip"
sudo -u askbayou sh -c "cp start_ask_bayou.sh /home/askbayou/start_ask_bayou.sh"
sudo -u askbayou sh -c "cp ../log4j/apiSynthesisServerLog4j2.xml /home/askbayou/resources/conf/apiSynthesisServerLog4j2.xml"
sudo -u askbayou sh -c "chmod +x /home/askbayou/*.sh"

cp ../systemd/askbayou.service /etc/systemd/system/
systemctl enable askbayou.service
