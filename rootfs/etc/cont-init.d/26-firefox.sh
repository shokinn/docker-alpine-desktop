#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

HOME=/home/app

# Make sure mandatory directories exist.
mkdir -p /config/logs

# Create profile and copy user.js
if [ ! -d "$HOME/.mozilla/firefox/awozinex.default" ]; then
	mkdir -p $HOME/.mozilla/firefox
	cp -r /defaults/firefox/* $HOME/.mozilla/firefox/
fi

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/logs
chown -R $USER_ID:$GROUP_ID $HOME/.mozilla
