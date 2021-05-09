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

say "Enabling Hardware Watchdog"
run "grep -qxF 'dtoverlay=pi3-disable-bt' /boot/config.txt || echo 'dtoverlay=pi3-disable-bt' | sudo tee -a /boot/config.txt"
run "perl -i -pe 's/^#RuntimeWatchdogSec=0/RuntimeWatchdogSec=10s/g' /etc/systemd/system.conf"
run "perl -i -pe 's/^#ShutdownWatchdogSec=10min/ShutdownWatchdogSec=10min/g' /etc/systemd/system.conf"


say "Installing Prerequisites"
run "apt -y update && apt -y full-upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git tcpdump wget"
run "npm --loglevel=error install -g gnomon"

say "Install VirtualHere"
run "(cd /usr/bin && wget https://virtualhere.com/sites/default/files/usbserver/vhusbdarm && chmod a+x vhusbdarm)"

say "Install Service file"
cat <<EOF > /etc/systemd/system/virtualhere.service
[Unit]
Description=VirtualHere USB Sharing
Requires=networking.service
After=networking.service
[Service]
ExecStartPre=/bin/sh -c 'logger VirtualHere settling...;sleep 1s;logger VirtualHere settled'
ExecStart=/usr/bin/vhusbdarm -c /etc/virtualhere/config.ini
Type=idle
[Install]
WantedBy=multi-user.target
EOF

run "systemctl deamon-reload"
run "systemctl enable virtualhere"
run "systemctl restart virtualhere"

say "done ... virtualhere config is @ /etc/virtualhere/settings.ini"
say "current settings:"
cat /etc/virtualhere/settings.ini

