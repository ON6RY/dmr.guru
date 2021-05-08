# Open DMR System #

### Why ###
Back to the roots ... 

### Install on Linux - Debian Buster based systems (Raspberry PI, Intel etc..) ###

## Install Master ##
Generates random hotspot and master password
```console
curl -sL https://git.io/Jm56P | sudo MASTER_PWD=$(cat /proc/sys/kernel/random/uuid) HOTSPOTS_PWD="$(cat /proc/sys/kernel/random/uuid)" bash
```

## Install Hytera Gateway Node ##
Just fill in the MASTER_PWD (generaterd above) and IP  and PORT of your system
```console
curl -sL https://git.io/Jm56L | sudo MASTER_PWD="" MASTER_IP="" MASTER_PORT="" bash
```

## Monitor ##
https://github.com/on3ure/HBMonv2

## OpenDMR Wireguard Install ##
Fill in WGIP and HOSTNAME ... return the publickey to the sysop
```console
curl -sL https://git.io/J39wq | sudo WGIP=172.16.100.X HOSTNAME=on0??? bash
```
