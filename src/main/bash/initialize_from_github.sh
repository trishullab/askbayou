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

# The single parameter to this script is the URL to binary Bayou release to be installed.
# e.g. http://release.askbayou.com/bayou-1.0.0.zip

git clone https://github.com/capergroup/bayou.git ~/bayou
cd ~/bayou
git checkout $1

cd tool_files/build_binary_release
chmod +x ./install_dependencies.sh
sudo ./install_dependencies.sh
./build.sh
python3 -m http.server &
cd ~/askbayou/src/main/bash
sudo ./initialize.sh http://127.0.0.1:8000/bayou-1.1.0.zip

trap 'kill $(jobs -p)' EXIT
