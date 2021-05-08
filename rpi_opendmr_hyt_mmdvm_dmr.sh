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
run "apt -y update && apt -y install build-essential python3-dev libsnmp-dev wget unzip"
rungnomon "pip3 install -U git+https://github.com/kti/python-netfilterqueue"
rungnomon "pip3 install scapy dmr_utils3 easysnmp"

say "Install Netfilter MMDVM MiM UDP packet patcher"
run "mkdir -p /opt/opendmr/bin && curl -sL https://git.io/J3Qe6 > /opt/opendmr/bin/netfilter_mmdvm.py && chmod +x /opt/opendmr/bin/netfilter_mmdvm.py"

say "Install binary blobs"
run "(cd /opt/opendmr/ && wget https://github.com/on3ure/dmr.guru/raw/master/hyt-gw-2.1-buster.zip && unzip hyt-gw-2.1-buster.zip)"

say "Cleanup blobs"
run "(rm /opt/opendmr/hyt-gw-2.1-buster.zip /opt/opendmr/hyt_gw_2.1_buster/reboot.sh /opt/opendmr/hyt_gw_2.1_buster/DMRGateway/DMRGateway.ini /opt/opendmr/hyt_gw_2.1_buster/DMRGateway/XLXHosts.txt /opt/opendmr/hyt_gw_2.1_buster/gw_hytera_mmdvm/gw_hytera_mmdvm.cfg)"

say "Making binary blobs executable"
run "(chmod +x /opt/opendmr/hyt_gw_2.1_buster/gw_hytera_mmdvm/gw_hytera_mmdvm && chmod +x /opt/opendmr/hyt_gw_2.1_buster/DMRGateway/DMRGateway)"

if [[ ! -f /opt/opendmr/hyt_gw_2.1_buster/DMRGateway/DMRGateway.ini ]]
then
	say "Configure DMRGateway settings"
	cat <<EOF > /opt/opendmr/hyt_gw_2.1_buster/DMRGateway/DMRGateway.ini
[General]
Timeout=20
RptAddress=127.0.0.1
RptPort=62032
LocalAddress=127.0.0.1
LocalPort=62031
RuleTrace=0
Daemon=0
Debug=0

[Log]
# Logging levels, 0=No logging
DisplayLevel=1
FileLevel=0
FilePath=.
FileRoot=DMRGateway

[Voice]
Enabled=1
Language=en_US
Directory=/opt/DMRGateway/Audio

[Info]
Latitude=${LAT}
Longitude=${LON}
Height=${HEIGHT}
Location=${LOCATION}
Description=Hytera Repeater
URL=www.opendmr-belgium.be

# OpenDMR
[DMR Network 1]
Enabled=1
Name=OpenDMR
Address=${MASTERIP}
Port=62031
PassAllTG=1
PassAllTG=2
PassAllPC=1
Password=Guru4me!
Debug=0
Id=${DMRID}
EOF
fi

if [[ ! -f /opt/opendmr/hyt_gw_2.1_buster/gw_hytera_mmdvm/gw_hytera_mmdvm.cfg ]]
then
	say "Configure Hytera MMDVM Gateway settings"
cat <<EOF > /opt/opendmr/hyt_gw_2.1_buster/gw_hytera_mmdvm/gw_hytera_mmdvm.cfg
# hytera_mmdvm DMRGateway Config by ON3URE
DMRGateway_address=127.0.0.1
DMRGateway_port=62031

DMRGateway_local_address=127.0.0.1
DMRGateway_local_port=62032

# hytera_mmdvm DMRGateway Repeater Ports

Hytera_RPT_PORT=50000
Hytera_RPT_AUDIO_PORT=50001
Hytera_RPT_RDAC_PORT=50002

####################################################################################
## hytera_mmdvm DMRGateway Location
####################################################################################

Location_Name=${LOCATION}
Location_Latitude=+${LAT}
Location_Longitude=+${LON}
Location_Homepage=http://opendmr-belgium.be
Location_Watt=${POWER}
Location_CC=01

####################################################################################
# sysop mailaddress and DMR ID 
####################################################################################

SYSOPEMAIL=info@opendmr-belgium.be
SYSOP_ID=${DMRID}

debug=0
EOF
fi

say "Add hytera system user"
run "useradd -r hytera 2>/dev/null"

say "Chown opendmr 2 hytera"
run "chown -R hytera:hytera /opt/opendmr"

### sytemctl stuff here

aay "Generate gw_hytera_mmdvm systemd service file"
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
