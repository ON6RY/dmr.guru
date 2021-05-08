# Open DMR Hytera -> MMDVM Raspberry PI Ethernet Node #

### Why ###
Easy install a Hytera ISPC -> MMDVM node

### Install on Raspberry PI Linux - Debian Buster ###

## Wireguard Install ##
Request a WGIP from the sysop ... Fill in WGIP and HOSTNAME (name of the repeater) ... return the publickey to the sysop ... test wireguard connectivity with network sysop
```console
curl -sL https://git.io/J39wq | sudo WGIP=172.16.100.X HOSTNAME=on0??? bash
```

## Ethernet Wireguard Router Install (disables WiFi) ##
Request a SUBNET from the network sysop, Apply your hyteras mac adress (hytera will receive fixed ip from DHCP server)
```console
curl -sL https://git.io/J3HAo | sudo SUBNET=172.16.10X.0 MAC=64:69:bc:04:7c:70 bash
```
