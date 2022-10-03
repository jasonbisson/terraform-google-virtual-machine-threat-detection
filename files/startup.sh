#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


BUCKET=${BUCKET}
BUCKET=${BINARY}

function download_archive () {
gsutil cp "${BUCKET}"/"${BINARY}"	/tmp
}

function start_miner () {
cd /tmp || exit
sudo chmod 777 "${BINARY}"
sudo ./"${BINARY}" &
sleep 180m
sudo shutdown
}

download_archive
start_miner

