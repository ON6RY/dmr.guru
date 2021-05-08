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

say "Disabling Ethernet"
run "grep -qxF 'dtoverlay=disable-wifi' /boot/config.txt || echo 'dtoverlay=disable-wifi' | sudo tee -a /boot/config.txt"

say "Disabling Bluetooth"
run "grep -qxF 'dtoverlay=disable-bt' /boot/config.txt || echo 'dtoverlay=disable-bt' | sudo tee -a /boot/config.txt"
run "systemctl disable hciuart"

say "Enabling Hardware Watchdog"
run "grep -qxF 'dtoverlay=pi3-disable-bt' /boot/config.txt || echo 'dtoverlay=pi3-disable-bt' | sudo tee -a /boot/config.txt"
run "perl -i -pe 's/^#RuntimeWatchdogSec=0/RuntimeWatchdogSec=10s/g' /etc/systemd/system.conf"
run "perl -i -pe 's/^#ShutdownWatchdogSec=10min/ShutdownWatchdogSec=10min/g' /etc/systemd/system.conf"


say "Installing Prerequisites"
run "apt -y update && apt -y full-upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git tcpdump dnsmasq"
run "npm --loglevel=error install -g gnomon"

RANGE=$(echo ${SUBNET} | perl -pe 's/\.[0-9]*$//g')
MYMAC=$(echo ${MAC} | tr '[:upper:]' '[:lower:]')

say "Configure dnsmasq"
grep -q '^interface=eth1' /etc/dnsmasq.conf || cat <<EOF >> /etc/dnsmasq.conf

### OpenDMR Config ON3URE ###
interface=eth1 # Listening interface
dhcp-range=${RANGE}.2,${RANGE}.100,255.255.255.0,24h # Pool of IP addresses served via DHCP
domain=ethernet     # Local wireless DNS domain
dhcp-option=option:router,${RANGE}.1
dhcp-host=${MYMAC},${RANGE}.25
listen-address=${RANGE}.1
EOF

run "systemctl enable dnsmasq"
run "systemctl start dnsmasq"

say "Enable IP4v Forwarding"
run "grep -qxF 'net.ipv4.ip_forward=1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf"
run "sysctl -w net.ipv4.ip_forward=1"

say "DHCP Server with fixed IP for hytera is running ;) You can plug in the hytera to the ethernet usb dongle ! The IP of the Hytera will be ${RANGE}.25"
