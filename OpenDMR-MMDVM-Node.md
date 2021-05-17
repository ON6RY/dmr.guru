# Open DMR Hytera -> MMDVM Raspberry PI Ethernet Node #

### Why ###
Easy install a MMDVM node

### Install on a Cloud nodeo - Debian Buster ###

## DMR Node install (HBLINK3) ##
Request a MasterIP from the SYSOP also feed sysop with DMRID, Location, Name, Coordinates and Height of the repeater
```console
curl -sL https://git.io/J3QZY | sudo CALL=ON0DIL DMRID=12345 LBIP=1.2.3.4 INTERNALIP=1.2.3.4 MASTERIP=10.132.0.123 MASTERHSIP=10.132.0.231 MASTERHSPORT=5002 LOCATION=Dendermonde LAT=0.0 LON=0.0 HEIGHT=40 POWER=25 RX=433.123 TX=444.123 bash
```
