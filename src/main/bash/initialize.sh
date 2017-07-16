#!/bin/bash

# Copyright 2017 Rice University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apt-get update
apt-get install unzip nfs-common

adduser --gecos '' --disabled-password askbayou

wget http://release.askbayou.com/bayou-1.0.0.zip

mv bayou-1.0.0.zip /home/askbayou/bayou-1.0.0.zip
sudo -u askbayou sh -c "unzip /home/askbayou/bayou-1.0.0.zip -d /home/askbayou"
sudo -u askbayou sh -c "rm -f /home/askbayou/bayou-1.0.0.zip"
sudo -u askbayou sh -c "cp start_ask_bayou.sh /home/askbayou/start_ask_bayou.sh"
sudo -u askbayou sh -c "cp ../log4j/apiSynthesisServerLog4j2.xml /home/askbayou/resources/conf/apiSynthesisServerLog4j2.xml"
sudo -u askbayou sh -c "chmod +x /home/askbayou/*.sh"
sudo -u askbayou sh -c "mkdir /home/askbayou/efs_logs"

cp ../fstab/fstab /etc/fstab

cp ../systemd/askbayou.service /etc/systemd/system/
systemctl enable askbayou.service
