#!/bin/bash

directory="$(dirname $(realpath $0))"
source $directory/config.sh

if [[ "$(which jq)" == '' ]]; then
	echo -e "\e[31mERROR: jq is currently not installed!\e[0m"
	exit 128
fi

if [[ "$(which curl)" == '' ]]; then
	echo -e "\e[31mERROR: curl is currently not installed!\e[0m"
	exit 129
fi

if [[ "${#master_ids[*]}" == 0 ]]; then
	echo -e "\e[31mERROR: master_ids is not specified!\e[0m"
	exit 130
fi

if [[ "$token" == "" ]]; then
	echo -e "\e[31mERROR: token is not specified!\e[0m"
	exit 131
fi

echo "[Unit]
Description=ShellBot
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash "$directory"/shellbotd.sh 
ExecStop=/bin/bash "$directory"/shellbotd.sh stop 
RemainAfterExit=yes
User=$USER

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/bot-shell.service
systemctl daemon-reload && systemctl start bot-shell && systemctl enable bot-shell