#!/bin/bash

directory="$(dirname $(realpath $0))"
source $directory/config.sh
file='/tmp/shellbotd'

if [[ "$1" == 'stop' ]]; then
	pkill shellbot
	exit 0
fi

touch $file

if ! [[ -r $file ]]; then
        echo "$file is unreadable!"
        exit 2
fi

if ! [[ -w $file ]]; then
        echo "$file is unwritable"
        exit 3
fi

start_bot() {
	$directory/shellbot.sh
}

[[ "$1" != "slave" ]] && {
        echo "$$" > "$file"
        $0 slave &
        start_bot &
}

while true; do
        [[ "$(cat "$file")" == "$$" ]] && {
                ping -c1 api.telegram.org && {
                        (( "$(curl -s "$tele_url/getUpdates" | jq -r ".result | length")" >= 10 )) && {
                                pkill shellbot.sh
                                start_bot &
                        }
                }
                sleep 60
        } || {
                [[ $(ps aux | tr -s " " | cut -d " " -f 2 | grep -o "$(cat "$file")") ]] && {
                        sleep 5
                } || {
                        echo "$$" > "$file"
                        $0 slave &
                }
        }
done