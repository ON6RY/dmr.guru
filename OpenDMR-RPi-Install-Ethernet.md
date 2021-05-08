# Open DMR System #

### Why ###
Back to the roots ... 

### Install on Linux - Debian Buster based systems (Raspberry PI, Intel etc..) ###

## OpenDMR Wireguard Install ##
Fill in WGIP and HOSTNAME ... return the publickey to the sysop
```console
curl -sL https://git.io/J39wq | sudo WGIP=172.16.100.X HOSTNAME=on0??? bash
```

## Ethernet Wireguard Router Install (disables WiFi) ##
```console
curl -sL https://git.io/J3HAo | sudo SUBNET=172.16.10X.0 MAC=64:69:bc:04:7c:70 bash
```
