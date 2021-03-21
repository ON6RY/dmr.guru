# Open DMR System #

### Why ###
Back to the roots ... 

### Install on Linux - Debian Buster based systems (Raspberry PI, Intel etc..) ###

## Install Master ##
```console
curl -sL https://raw.githubusercontent.com/on3ure/dmr.guru/master/hytera_node_install.sh | sudo MASTER_PWD=$(cat /proc/sys/kernel/random/uuid) HOTSPOTS_PWD="$(cat /proc/sys/kernel/random/uuid)" bash
```

## Install Hytera Gateway Node ##
```console
curl -sL https://raw.githubusercontent.com/on3ure/dmr.guru/master/hytera_node_install.sh | sudo MASTER_PWD="" MASTER_IP="" MASTER_PORT="" bash
```
