#!/bin/bash

directory="$(dirname $(realpath $0))"
source $directory/config.sh
last_id=0

reply_to_message() {
	curl -s "$tele_url/sendMessage" \
		--data-urlencode "chat_id=$1" \
		--data-urlencode "reply_to_message_id=$2" \
		--data-urlencode "text=$3"
}

send() {
	curl -s "$tele_url/sendMessage" \
		--data-urlencode "chat_id=$1" \
		--data-urlencode "text=$2"
}

check_update() {
	updates="$(curl -s "$tele_url/getUpdates" \
		--data-urlencode "offset=$(($last_id + 1))" \
		--data-urlencode "timeout=5")"
	updates_count=$(echo "$updates" | jq -r ".result | length")
	last_id=$(echo "$updates" | jq -r ".result[$(( "$updates_count" - 1 ))].update_id")
}

parse_json() {
	message="$(echo "$updates" | jq ".result[$i].message")"
	chat_id="$(echo "$message" | jq ".chat.id")"
	message_text="$(echo "$message" | jq ".text")"
	message_id="$(echo "$message" | jq ".message_id")"
	reply_id="$(echo "$message" | jq ".reply_to_message.message_id")"
	from_id="$(echo "$message" | jq ".from.id")"
}

write_log() {
	date +%F-%T >> $directory/shell.log
	echo "$updates" | jq ".result[$i]" >> $directory/shell.log
}

alert() {
	if [[ "$enable_alert" == "true" ]]; then
		for master_id in ${master_ids[*]}; do
			send "$master_id" "Message from unauthorized users:
			$message"
		done
	fi
}

admin_log() {
	date +%F-%T >> $directory/admin.log
	echo "User $1 not in master_ids list. Check your bot privacy settings.
	Message:
	$message" >> $directory/admin.log
}

bash_command() {
	matches=0
	for master_id in ${master_ids[*]}; do
		if [[ "$from_id" == "$master_id" ]]; then
			matches=$(($matches + 1))
		fi
	done
	if [[ $matches == 1 ]]; then
		response_text="$(bash -c "$message_text 2>&1")"
		while [ ${#response_text} -gt $response_length ]; do
			reply_to_message "$chat_id" "$message_id" "${response_text:0:response_length}"
			response_text=${response_text:response_length}
		done
		reply_to_message "$chat_id" "$message_id" "$response_text" 
	else
		admin_log $from_id
		alert
	fi
}

while true; do
	ping -c1 $(echo "$tele_url" | cut -d '/' -f 3) 2>&1 > /dev/null && {
		check_update
		for ((i=0; i<"$updates_count"; i++)); do
			parse_json
			write_log
			if [[ $message_text == 'null' ]]; then
				continue
			fi
			message_text="$(echo "$message_text" | sed --sandbox 's#\\"#"#g;s#\\\\#\\#g;s/^"//;s/"$//')"
			case $message_text in
				'ping'*)
					reply_to_message "$chat_id" "$message_id" "pong"
				;;
				*)
					bash_command
				;;
			esac
		done
	}
done