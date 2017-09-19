#!/bin/bash -xe

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Make it easy to run iperf3.
echo "iperf3 -c <EXT_IP> -p 80 -i 1 -t 30 -P 8 -V" > /tmp/run_iperf_to_ext.sh
chmod 755 /tmp/run_iperf_to_ext.sh
echo "iperf3 -c <INT_IP> -p 80 -i 1 -t 30 -P 8 -V" > /tmp/run_iperf_to_int.sh
chmod 755 /tmp/run_iperf_to_int.sh

# Setup iperf3.
apt-get update
apt-get install -y iperf3

cat > /etc/systemd/system/iperf3.service <<EOF
[Unit]
Description=iPerf 3 Server
[Service]
Restart=always
TimeoutStartSec=0
RestartSec=3
WorkingDirectory=/tmp
ExecStart=/usr/bin/iperf3 -s -p 80
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable iperf3
systemctl start iperf3
