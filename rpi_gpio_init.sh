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

mkdir -p /opt/bin
say "Install gpio.sh"
cat <<EOF > /opt/bin/gpio.sh
#!/bin/bash

echo 21 > /sys/class/gpio/export 
echo out > /sys/class/gpio/gpio21/direction
echo 1 > /sys/class/gpio/gpio21/value

echo 20 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio20/direction

touch /tmp/booting
FILE=/tmp/booting

while :
do
        if test -f "${FILE}"; then
                echo 1 > /sys/class/gpio/gpio20/value && sleep 1 && echo 0 > /sys/class/gpio/gpio20/value && sleep 1
        else
                echo 1 > /sys/class/gpio/gpio20/value
                sleep 60
        fi
done
EOF
chmod +x /opt/bin/gpio.sh

say "Install last10mins.sh"
cat <<EOF > /opt/bin/last10min.sh
#!/bin/bash

declare -A month

for i in {1..12};do
    LANG=C printf -v var "%(%b)T" $(((i-1)*31*86400))
    month[$var]=$i
  done

printf -v now "%(%s)T" -1
printf -v ref "%(%m%d%H%M%S)T" $((now-600))

while read line;do
    printf -v crt "%02d%02d%02d%02d%02d" ${month[${line:0:3}]} \
        $((10#${line:4:2})) $((10#${line:7:2})) $((10#${line:10:2})) \
        $((10#${line:13:2}))
    # echo " $crt < $ref ??"   # Uncomment this line to print each test
    [ $crt -gt $ref ] && break
done
cat
EOF
chmod +x /opt/bin/last10min.sh

say "Install Service file"
cat <<EOF > /etc/systemd/system/gpio_init.service
[Unit]
Description=GPIO Init
Requires=gw_hytera_mmdvm.service
User=root
After=gw_hytera_mmdvm.service
[Service]
ExecStart=/opt/bin/gpio.sh
Type=simple
[Install]
WantedBy=multi-user.target
EOF

run "systemctl daemon-reload"
run "systemctl enable gpio_init"
run "systemctl restart gpio_init"

