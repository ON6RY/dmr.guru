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

run "apt -y update && apt -y full-upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git tcpdump"
run "npm --loglevel=error install -g gnomon"

say "Installing Wireguard"
run "apt -y install wireguard"

if [[ ! -f /etc/wireguard/privatekey ]]
then
say "Generating Keys"
run "cd /etc/wireguard && umask 077 && wg genkey | tee privatekey | wg pubkey > publickey"
PRIVKEY=$(cat /etc/wireguard/privatekey)
say "Generate /etc/wireguard/wg0.conf"
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = ${PRIVKEY}
Address = ${WGIP}/32

[Peer]
PublicKey = 7l+VLVUqzPdRNynvzBYS8Eiew98X9OsVDkQcv+GXz3w=
AllowedIPs = 10.132.0.0/20,172.16.100.0/24
Endpoint = 104.199.103.239:51820

PersistentKeepalive = 15
EOF
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
fi

say "Modify hostname to ${HOSTNAME}"
run "perl -i -pe 's/raspberrypi/${HOSTNAME}/g' /etc/hosts"
run "perl -i -pe 's/raspberrypi/${HOSTNAME}/g' /etc/hostname"

PUBKEY=$(cat /etc/wireguard/publickey)
say "WireGuard Public Key: ${PUBKEY}"
say "Send the key to the wireguard sysop"
say "You can check the status of wireguard with the command: 'sudo wg'" 
say "System needs a reboot !"



