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
# hblink.cfg
# python3 bridge.py
# PROGRAM-WIDE PARAMETERS GO HERE
# PATH - working path for files, leave it alone unless you NEED to change it
# PING_TIME - the interval that peers will ping the master, and re-try registraion
#           - how often the Master maintenance loop runs
# MAX_MISSED - how many pings are missed before we give up and re-register
#           - number of times the master maintenance loop runs before de-registering a peer
#
# ACLs:
#
# Access Control Lists are a very powerful tool for administering your system.
# But they consume packet processing time. Disable them if you are not using them.
# But be aware that, as of now, the configuration stanzas still need the ACL
# sections configured even if you're not using them.
#
# REGISTRATION ACLS ARE ALWAYS USED, ONLY SUBSCRIBER AND TGID MAY BE DISABLED!!!
#
# The 'action' May be PERMIT|DENY
# Each entry may be a single radio id, or a hypenated range (e.g. 1-2999)
# Format:
# 	ACL = 'action:id|start-end|,id|start-end,....'
#		--for example--
#	SUB_ACL: DENY:1,1000-2000,4500-60000,17
#
# ACL Types:
# 	REG_ACL: peer radio IDs for registration (only used on HBP master systems)
# 	SUB_ACL: subscriber IDs for end-users
# 	TGID_TS1_ACL: destination talkgroup IDs on Timeslot 1
# 	TGID_TS2_ACL: destination talkgroup IDs on Timeslot 2
#
# ACLs may be repeated for individual systems if needed for granularity
# Global ACLs will be processed BEFORE the system level ACLs
# Packets will be matched against all ACLs, GLOBAL first. If a packet 'passes'
# All elements, processing continues. Packets are discarded at the first
# negative match, or 'reject' from an ACL element.
#
# If you do not wish to use ACLs, set them to 'PERMIT:ALL'
# TGID_TS1_ACL in the global stanza is used for OPENBRIDGE systems, since all
# traffic is passed as TS 1 between OpenBridges
[GLOBAL]
PATH: ./
PING_TIME: 5
MAX_MISSED: 3
USE_ACL: True
REG_ACL: PERMIT:ALL
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL


# NOT YET WORKING: NETWORK REPORTING CONFIGURATION
#   Enabling "REPORT" will configure a socket-based reporting
#   system that will send the configuration and other items
#   to a another process (local or remote) that may process
#   the information for some useful purpose, like a web dashboard.
#
#   REPORT - True to enable, False to disable
#   REPORT_INTERVAL - Seconds between reports
#   REPORT_PORT - TCP port to listen on if "REPORT_NETWORKS" = NETWORK
#   REPORT_CLIENTS - comma separated list of IPs you will allow clients
#       to connect on. Entering a * will allow all.
#
# ****FOR NOW MUST BE TRUE - USE THE LOOPBACK IF YOU DON'T USE THIS!!!****
[REPORTS]
REPORT: True
REPORT_INTERVAL: 60
REPORT_PORT: 4321
REPORT_CLIENTS: 127.0.0.1


# SYSTEM LOGGER CONFIGURAITON
#   This allows the logger to be configured without chaning the individual
#   python logger stuff. LOG_FILE should be a complete path/filename for *your*
#   system -- use /dev/null for non-file handlers.
#   LOG_HANDLERS may be any of the following, please, no spaces in the
#   list if you use several:
#       null
#       console
#       console-timed
#       file
#       file-timed
#       syslog
#   LOG_LEVEL may be any of the standard syslog logging levels, though
#   as of now, DEBUG, INFO, WARNING and CRITICAL are the only ones
#   used.
#
[LOGGER]
LOG_FILE: /tmp/hblink.log
LOG_HANDLERS: console-timed
LOG_LEVEL: DEBUG
LOG_NAME: HBlink

# DOWNLOAD AND IMPORT SUBSCRIBER, PEER and TGID ALIASES
# Ok, not the TGID, there's no master list I know of to download
# This is intended as a facility for other applcations built on top of
# HBlink to use, and will NOT be used in HBlink directly.
# STALE_DAYS is the number of days since the last download before we
# download again. Don't be an ass and change this to less than a few days.
[ALIASES]
TRY_DOWNLOAD: True
PATH: ./
PEER_FILE: peer_ids.json
SUBSCRIBER_FILE: subscriber_ids.json
TGID_FILE: talkgroup_ids.json
PEER_URL: https://www.radioid.net/static/rptrs.json
SUBSCRIBER_URL: https://www.radioid.net/static/users.json
STALE_DAYS: 7

# OPENBRIDGE INSTANCES - DUPLICATE SECTION FOR MULTIPLE CONNECTIONS
# OpenBridge is a protocol originall created by DMR+ for connection between an
# IPSC2 server and Brandmeister. It has been implemented here at the suggestion
# of the Brandmeister team as a way to legitimately connect HBlink to the
# Brandemiester network.
# It is recommended to name the system the ID of the Brandmeister server that
# it connects to, but is not necessary. TARGET_IP and TARGET_PORT are of the
# Brandmeister or IPSC2 server you are connecting to. PASSPHRASE is the password
# that must be agreed upon between you and the operator of the server you are
# connecting to. NETWORK_ID is a number in the format of a DMR Radio ID that
# will be sent to the other server to identify this connection.
# other parameters follow the other system types.
#
# ACLs:
# OpenBridge does not 'register', so registration ACL is meaningless.
# Proper OpenBridge passes all traffic on TS1.
# HBlink can extend OPB to use both slots for unit calls only.
# Setting "BOTH_SLOTS" True ONLY affects unit traffic!
# Otherwise ACLs work as described in the global stanza
[OBP-1]
MODE: OPENBRIDGE
ENABLED: False
IP:
PORT: 62035
NETWORK_ID: 3129100
PASSPHRASE: password
TARGET_IP: 1.2.3.4
TARGET_PORT: 62035
BOTH_SLOTS: True
USE_ACL: True
SUB_ACL: DENY:1
TGID_ACL: PERMIT:ALL

# MASTER INSTANCES - DUPLICATE SECTION FOR MULTIPLE MASTERS
# HomeBrew Protocol Master instances go here.
# IP may be left blank if there's one interface on your system.
# Port should be the port you want this master to listen on. It must be unique
# and unused by anything else.
# Repeat - if True, the master repeats traffic to peers, False, it does nothing.
#
# MAX_PEERS -- maximun number of peers that may be connect to this master
# at any given time. This is very handy if you're allowing hotspots to
# connect, or using a limited computer like a Raspberry Pi.
#
# ACLs:
# See comments in the GLOBAL stanza
[MASTER-1]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 10
EXPORT_AMBE: False
IP: 
PORT: 62030
PASSPHRASE: ${MASTER_PWD}
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:206,2061,2062
TGID_TS2_ACL: PERMIT:8

[HOTSPOTS-1]
MODE: MASTER
ENABLED: True
REPEAT: True
MAX_PEERS: 10
EXPORT_AMBE: False
IP: 
PORT: 62031
PASSPHRASE: ${HOTSPOTS_PWD}
GROUP_HANGTIME: 5
USE_ACL: True
REG_ACL: DENY:1
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:206,2061,2062
TGID_TS2_ACL: PERMIT:8

# PEER INSTANCES - DUPLICATE SECTION FOR MULTIPLE PEERS
# There are a LOT of errors in the HB Protocol specifications on this one!
# MOST of these items are just strings and will be properly dealt with by the program
# The TX & RX Frequencies are 9-digit numbers, and are the frequency in Hz.
# Latitude is an 8-digit unsigned floating point number.
# Longitude is a 9-digit signed floating point number.
# Height is in meters
# Setting Loose to True relaxes the validation on packets received from the master.
# This will allow HBlink to connect to a non-compliant system such as XLXD, DMR+ etc.
#
# ACLs:
# See comments in the GLOBAL stanza
[BRANDMEISTER]
MODE: PEER
ENABLED: False
LOOSE: False
EXPORT_AMBE: False
IP: 
PORT: 54001
MASTER_IP: 194.146.121.130
MASTER_PORT: 62031
PASSPHRASE: whatever
CALLSIGN: HER0
RADIO_ID: 123456
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 3
LATITUDE: 38.0000
LONGITUDE: -095.0000
HEIGHT: 75
LOCATION: Wherever
DESCRIPTION: Whatever
URL: wtf.be
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 5
OPTIONS:
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL

[XLX-1]
MODE: XLXPEER
ENABLED: False
LOOSE: True
EXPORT_AMBE: False
IP: 
PORT: 54002
MASTER_IP: 172.16.1.1
MASTER_PORT: 62030
PASSPHRASE: passw0rd
CALLSIGN: W1ABC
RADIO_ID: 312000
RX_FREQ: 449000000
TX_FREQ: 444000000
TX_POWER: 25
COLORCODE: 1
SLOTS: 1
LATITUDE: 38.0000
LONGITUDE: -095.0000
HEIGHT: 75
LOCATION: Anywhere, USA
DESCRIPTION: This is a cool repeater
URL: www.w1abc.org
SOFTWARE_ID: 20170620
PACKAGE_ID: MMDVM_HBlink
GROUP_HANGTIME: 5
XLXMODULE: 4004
USE_ACL: True
SUB_ACL: DENY:1
TGID_TS1_ACL: PERMIT:ALL
TGID_TS2_ACL: PERMIT:ALL
EOF

say "Generate rules.py"
cat <<EOF > rules.py
'''
THIS EXAMPLE WILL NOT WORK AS IT IS - YOU MUST SPECIFY YOUR OWN VALUES!!!

This file is organized around the "Conference Bridges" that you wish to use. If you're a c-Bridge
person, think of these as "bridge groups". You might also liken them to a "reflector". If a particular
system is "ACTIVE" on a particular conference bridge, any traffid from that system will be sent
to any other system that is active on the bridge as well. This is not an "end to end" method, because
each system must independently be activated on the bridge.

The first level (e.g. "WORLDWIDE" or "STATEWIDE" in the examples) is the name of the conference
bridge. This is any arbitrary ASCII text string you want to use. Under each conference bridge
definition are the following items -- one line for each HBSystem as defined in the main HBlink
configuration file.

    * SYSTEM - The name of the sytem as listed in the main hblink configuration file (e.g. hblink.cfg)
        This MUST be the exact same name as in the main config file!!!
    * TS - Timeslot used for matching traffic to this confernce bridge
        XLX connections should *ALWAYS* use TS 2 only.
    * TGID - Talkgroup ID used for matching traffic to this conference bridge
        XLX connections should *ALWAYS* use TG 9 only.
    * ON and OFF are LISTS of Talkgroup IDs used to trigger this system off and on. Even if you
        only want one (as shown in the ON example), it has to be in list format. None can be
        handled with an empty list, such as " 'ON': [] ".
    * TO_TYPE is timeout type. If you want to use timers, ON means when it's turned on, it will
        turn off afer the timout period and OFF means it will turn back on after the timout
        period. If you don't want to use timers, set it to anything else, but 'NONE' might be
        a good value for documentation!
    * TIMOUT is a value in minutes for the timout timer. No, I won't make it 'seconds', so don't
        ask. Timers are performance "expense".
    * RESET is a list of Talkgroup IDs that, in addition to the ON and OFF lists will cause a running
        timer to be reset. This is useful   if you are using different TGIDs for voice traffic than
        triggering. If you are not, there is NO NEED to use this feature.
'''

BRIDGES = {
    'BENL': [
            {'SYSTEM': 'MASTER-1',    'TS': 1, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [206], 'RESET': []},
            {'SYSTEM': 'HOTSPOTS-1',  'TS': 1, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [206], 'RESET': []}
        ],
    'BEFR': [
            {'SYSTEM': 'MASTER-1',    'TS': 1, 'TGID': 2062, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [2061, 206], 'RESET': []},
            {'SYSTEM': 'HOTSPOTS-1',  'TS': 1, 'TGID': 2061, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [2061, 206], 'RESET': []}
        ],
    'BEARS': [
            {'SYSTEM': 'MASTER-1',    'TS': 1, 'TGID': 206, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'HOTSPOTS-1',  'TS': 1, 'TGID': 206, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [], 'OFF': [], 'RESET': []}
        ],
    'LOCAL': [
            {'SYSTEM': 'MASTER-1',    'TS': 2, 'TGID': 8, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [8], 'OFF': [], 'RESET': []},
            {'SYSTEM': 'HOTSPOTS-1',  'TS': 2, 'TGID': 8, 'ACTIVE': True, 'TIMEOUT': 15, 'TO_TYPE': 'ON',  'ON': [8], 'OFF': [], 'RESET': []}
        ]
}

'''
list the names of each system that should bridge unit to unit (individual) calls.
'''

'''
UNIT = ['ONE', 'TWO']
'''
UNIT = []

'''
This is for testing the syntax of the file. It won't eliminate all errors, but running this file
like it were a Python program itself will tell you if the syntax is correct!
'''

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