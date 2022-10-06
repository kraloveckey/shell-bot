#!/bin/bash

###########################################################

master_ids=(USER_ID)	##### insert your Telegram ID here
token='TOKEN_BOT'	##### insert your token here

###########################################################

api_url='https://api.telegram.org'
tele_url="$api_url/bot$token"
response_length=512     ##### default response length is 512, can be increased
enable_alert="true"       ##### enable or disable sending alerts to PM


###########################################################