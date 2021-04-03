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

run "apt -y update && apt -y upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git cpanminus libpcap-dev"
run "npm --loglevel=error install -g gnomon"
run "cpanm -n -f Net::Pcap::Easy"

say "Installing Hytera Hombrew (takes a long time to build!)"
rungnomon "python3 -m pip install hytera-homebrew-bridge --upgrade"

say "Add hytera system user & create direcotry & Generate settings"
run "useradd -r hytera 2>/dev/null && mkdir -p /opt/guru-hytera-node 2>/dev/null"

if [[ ! -f /opt/guru-hytera-node/settings.ini ]]
then
	say "Configure settings"
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
fi

say "Generate hytera systemd service file"
cat <<EOF > /etc/systemd/system/hytera.service
[Unit]
Description=hytera-homebrew-bridge.py
Wants=network.target
After=network.target

[Service]
Type=simple
Environment=HOME=/opt/guru-hytera-node
WorkingDirectory=/opt/guru-hytera-node

User=hytera

Nice=1
TimeoutSec=300

ExecStart=hytera-homebrew-bridge.py settings.ini

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

say "Write last heard script"
cat <<EOF > /opt/guru-hytera-node/check_last_heard
#!/bin/bash

FILE=/tmp/last_heard
if [[ -f "${FILE}" ]]; then
    if test "$(find ${FILE} -mmin +5)"; then
	    /usr/bin/systemctl restart hytera
	    rm /tmp/last_heard
    fi
fi
EOF
run "chmod +x /opt/guru-hytera-node/check_last_heard"

say "Install last heard check crontab"
(crontab -l 2>/dev/null && echo "*/5 * * * * /opt/guru-hytera-node/check_last_heard") | crontab -
crontab -l 2>/dev/null | sort | grep -v "#" | uniq | crontab -
run "crontab -l 2>/dev/null"

say "Install last-heard UDP hytera pcap check"
cat <<EOF > /opt/guru-hytera-node/last_heard
#!/usr/bin/perl
use strict;
use warnings;
use Net::Pcap::Easy;
use File::Touch;

print "Hytera Last Heard\n";
 
my \$npe = Net::Pcap::Easy->new(
    dev              => "ens4",
    filter           => "udp port 50000",
    packets_per_loop => 10,
    bytes_to_capture => 1024,
    promiscuous      => 1,
 
    udp_callback => sub {
        my (\$npe, \$ether, \$ip, \$tcp, \$header ) = @_;

	File::Touch->new()->touch("/tmp/last_heard");
    },
);
 
1 while \$npe->loop;
EOF
chmod +x /opt/guru-hytera-node/last_heard

say "Generate last-heard systemd service file"
cat <<EOF > /etc/systemd/system/last-heard.service
[Unit]
Description=hytera last heard
Wants=network.target
After=network.target

[Service]
Type=simple
Environment=HOME=/opt/guru-hytera-node
WorkingDirectory=/opt/guru-hytera-node

#User=root

Nice=1
TimeoutSec=300

ExecStart=/usr/bin/perl last_heard

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF


say "Configure systemd"
run "systemctl daemon-reload"
run "systemctl enable hytera"
run "systemctl restart hytera"
run "systemctl enable last-heard"
run "systemctl restart last-heard"

say "Add Hytera node to the master (see pwd settings.ini dump beneeth)"
cat /opt/guru-hytera-node/settings.ini


