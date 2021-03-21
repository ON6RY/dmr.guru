#!/bin/bash
# build for debian buster (should work on raspberry pi and x86 and propably ubuntu 2)

run() {
  exec=$1
  printf "\x1b[38;5;104m -- ${exec}\x1b[39m\n"
  eval ${exec}
}

rungnomon () {
  exec=$1
  printf "\x1b[38;5;104m -- ${exec}\x1b[39m\n"
  eval ${exec} | gnomon --ignore-blank -h
}

say () {
  say=$1
  printf "\x1b[38;5;220m${say}\x1b[38;5;255m\n"
}

say "Installing Prerequisites"
run "apt -y update && apt -y upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git"
run "npm --loglevel=error install -g gnomon"

say "Installing Hytera Hombrew (takes a long time to build!)"
rungnomon "python3 -m pip install hytera-homebrew-bridge --upgrade"

say "Add hytera system user & create direcotry & Generate settings"
run "useradd -r hytera && mkdir -p /opt/guru-hytera-node"

cat <<EOF > /opt/guru-hytera-node/settings.ini
# Hytera IPSC configuration
[ip-site-connect]
# Local IP on which you listen for Hytera repeater connection
ip = 0.0.0.0
p2p_port = 50000
dmr_port = 50001
rdac_port = 50002

[homebrew]
protocol=mmdvm
local_ip = 0.0.0.0
master_ip = ${MASTER_IP}
master_port = ${MASTER_PORT}
password = ${MASTER_PWD}
EOF

say "Generate systemd service file"
cat <<EOF > /etc/systemd/system/hytera.service
[Unit]
Description=hytera-homebrew-bridge.py
Wants=network.target
After=network.target

[Service]
Type=simple
Environment=HOME=/opt/guru-hytera-node
WorkingDirectory=/opt/guru-hytera-node

Nice=1
TimeoutSec=300

ExecStart=hytera-homebrew-bridge.py settings.ini

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

say "Configure systemd"
run "systemctl daemon-reload"
run "systemctl enable hytera"
run "systemctl restart hytera"

say "Add Hytera node to the master (see pwd settings.ini dump beneeth)"
cat /opt/guru-hytera-node/settings.ini


