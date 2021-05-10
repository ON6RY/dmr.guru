# Open DMR Hytera -> MMDVM Raspberry PI WiFi Node #

### Why ###
Easy install a Hytera ISPC -> MMDVM node

### Install on Raspberry PI Linux - Debian Buster ###

## Burn a buster lite image to an sd card. After burning mount the SD card and put 2 files on the boot partitition. ##
- an empty file called ssh 
- a file called wpa_supplicant.conf with following content:

```console
country=BE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="YOURSSID"
    psk="YOURPSKPASSPHRASE"
}
```

## Wireguard Install ##
Request a WGIP from the sysop ... Fill in WGIP and HOSTNAME (name of the repeater) ... return the publickey to the sysop ... test wireguard connectivity with network sysop
```console
curl -sL https://git.io/J39wq | sudo WGIP=172.16.100.X HOSTNAME=on0??? bash
```

## Ethernet Wireguard Router Install over WiFi ##
Request a SUBNET from the network sysop, Apply your hyteras mac adress (hytera will receive fixed ip from DHCP server)
```console
curl -sL https://git.io/J3FQa | sudo SUBNET=172.16.10X.0 MAC=64:69:bc:04:7c:70 bash
```

## DMR Node install (DMRGateway | Hytera MMDVM Gateway | Netfilter Hytera Patcher) ##
Request a MasterIP from the SYSOP also feed sysop with DMRID, Location, Name, Coordinates and Height of the repeater
```console
curl -sL https://git.io/J3QZY | sudo DMRID=12345 MASTERIP=10.132.0.123 LOCATION=Dendermonde LAT=0.0 LON=0.0 HEIGHT=40 POWER=25 bash
```

## Install VirtualHere (binds on 0.0.0.0:7575) ##
Install virtualhere to get usb access to repeater (remote update of codeplugs and firmware)
```console
curl -sL https://git.io/J3Fsj | sudo bash
```
