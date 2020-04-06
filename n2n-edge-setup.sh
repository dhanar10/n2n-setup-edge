#!/usr/bin/env bash

set -e
set -o pipefail

CONFIG_FILE=$1

if [ -z $CONFIG_FILE ]; then
	echo "Usage: $0 CONFIG_FILE"
	exit 1
fi

if ! which edge > /dev/null; then
	sudo apt update
	sudo apt install n2n
fi

CONFIG_FILE_NAME=$(basename $CONFIG_FILE)

mkdir -p /etc/n2n/edge
cp $CONFIG_FILE /etc/n2n/edge/$CONFIG_FILE_NAME

cat << EOF | sudo tee /etc/systemd/system/edge@.service
[Unit]
Description=n2n edge
After=network-online.target
Wants=network-online.target

[Service]
EnvironmentFile=/etc/n2n/edge/%i
ExecStart=$(which edge) -f -a \$N2N_IP_ADDRESS -c \$N2N_COMMUNITY -k \$N2N_KEY -l \$N2N_SUPERNODE -u $(id -u nobody) -g $(id -g nobody) -r

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable edge@$CONFIG_FILE_NAME
sudo systemctl start edge@$CONFIG_FILE_NAME
