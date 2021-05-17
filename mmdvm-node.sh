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
run "apt -y update && apt -y upgrade && apt -y install git npm python3-pip python3-wheel python3-setuptools python3-setuptools-git netcat wget"
run "npm --loglevel=error install -g gnomon"

say "Add hblink system user"
run "useradd -r hblink"

say "Installing HBLink3"
run "mkdir -p /opt/"
run "cd /opt"
run "rm -fr hblink3 > /dev/null 2>&1"
run "git clone https://github.com/HBLink-org/hblink3.git"
run "cd hblink3"
rungnomon "python3 -m pip install -r requirements.txt --upgrade"

say "Generate hblink.cfg"
cat <<EOF > hblink.cfg
[GLOBAL]
PATH: ./
PING_TIME: 5
MAX_MISSED: 3
USE_ACL: True
REG_ACL: PERMIT:ALL
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: 127.0.0.1

[LOGGER]
LOG_FILE: /tmp/hblink.log
LOG_HANDLERS: console-timed
LOG_LEVEL: INFO
LOG_NAME: HBlink

[ALIASES]
TRY_DOWNLOAD: True
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
STALE_DAYS: 7

[LOCAL]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 100
EXPORT_AMBE: False
IP: ${LBIP}
PORT: 62031
PASSPHRASE: Guru4me!
GROUP_HANGTIME: 0
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:206,2061,2062
TGID_TS2_ACL: PERMIT:9

[REPEATER]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 1
EXPORT_AMBE: False
IP: ${INTERNALIP}
PORT: 62031
PASSPHRASE: Guru4me!
GROUP_HANGTIME: 0
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:206,2061,2062
TGID_TS2_ACL: PERMIT:9

[MASTER]
MODE: PEER
ENABLED: True
LOOSE: False
EXPORT_AMBE: False
IP:
PORT: 54001
MASTER_IP: ${MASTERIP}
MASTER_PORT: 62031
PASSPHRASE: Guru4me!
CALLSIGN: ${CALL}
RADIO_ID: ${DMRID}
RX_FREQ: ${RX}
TX_FREQ: ${TX}
TX_POWER: ${POWER}
COLORCODE: 1
SLOTS: 3
LATITUDE: ${LAT}
LONGITUDE: ${LON}
HEIGHT: ${HEIGHT}
LOCATION: ${LOCATION}
DESCRIPTION: Local
URL: opendmr-belgium.be
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 0
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: DENY:ALL
TGID_TS2_ACL: PERMIT:206,2061,2062

[ON0DIL-LOCAL]
MODE: PEER
ENABLED: True
LOOSE: False
EXPORT_AMBE: False
IP:
PORT: 54002
MASTER_IP: ${MASTERHSIP}
MASTER_PORT: ${MASTERHSPORT}
PASSPHRASE: Guru4me!
CALLSIGN: ${CALL}
RADIO_ID: ${DMRID}
RX_FREQ: ${RX}
TX_FREQ: ${TX}
TX_POWER: ${POWER} 
COLORCODE: 1
SLOTS: 3
LATITUDE: ${LAT}
LONGITUDE: ${LON}
HEIGHT: ${HEIGHT}
LOCATION: ${LOCATION}
DESCRIPTION: Local
URL: opendmr-belgium.be
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 0
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: DENY:ALL
TGID_TS2_ACL: PERMIT:9
EOF

say "Generate rules.py"
cat <<EOF > rules.py
BRIDGES = {
    'BENL': [
            {'SYSTEM': 'LOCAL',     'TS': 1, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'REPEATER',  'TS': 1, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'MASTER',    'TS': 2, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []}
        ],
    'BEFR': [
            {'SYSTEM': 'LOCAL',     'TS': 1, 'TGID': 2062, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'REPEATER',  'TS': 1, 'TGID': 2062, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'MASTER',    'TS': 2, 'TGID': 2062, 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []}
        ],
    'BEARS': [
            {'SYSTEM': 'LOCAL',     'TS': 1, 'TGID': 206 , 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'REPEATER',  'TS': 1, 'TGID': 206,  'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'MASTER',    'TS': 2, 'TGID': 206 , 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []}
        ],
    'ON0DIL-LOCAL': [
            {'SYSTEM': 'LOCAL',           'TS': 2, 'TGID': 9 , 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'REPEATER',        'TS': 2, 'TGID': 9 , 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'ON0DIL-LOCAL',    'TS': 2, 'TGID': 9 , 'ACTIVE': True, 'TIMEOUT': 1440, 'TO_TYPE': 'NONE',  'ON': [], 'OFF': [], 'RESET': []}
        ]
}

UNIT = []

if __name__ == '__main__':
    from pprint import pprint
    pprint(BRIDGES)
    print(UNIT)
EOF

say "Chown hblink"
run "chown -R hblink /opt/hblink3"

say "Generate systemd service file"
cat <<EOF > /etc/systemd/system/hblink3-bridge.service
[Unit]
Description=hblink3 bridge service
Wants=network.target
After=network.target

User=hblink

[Service]
Type=simple
Environment=HOME=/opt/hblink3
WorkingDirectory=/opt/hblink3

Nice=1
TimeoutSec=300

ExecStart=/usr/bin/python3 bridge.py

Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

say "Configure systemd"
run "systemctl daemon-reload"
run "systemctl enable hblink3-bridge"
run "systemctl restart hblink3-bridge"
