# shell-bot

Simple Telegram bot written on bash that execute commands in shell.
You can send commands to your server without SSH access, or open SSH port,
or something like this. Support many master ID's, you can provide access
for others.

Requirements: `bash, curl, jq`.

How to use:
1. Clone git repository
2. Insert bot token and your Telegram ID to config.sh
3. 
   
   a) Run <code>shellbotd.sh</code> in tmux/screen.

	or

   b) Run <code>./install.sh</code> for create, enable and start systemd unit (better way).

For checking connection send <code>ping</code> in the chat.