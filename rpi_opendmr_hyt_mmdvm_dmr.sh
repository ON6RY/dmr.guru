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

### config everything here

say "Add hytera system user"
run "useradd -r hytera 2>/dev/null"

say "Chown opendmr 2 hytera"
run "chown -R hytera:hytera /opt/opendmr"

### sytemctl stuff here
