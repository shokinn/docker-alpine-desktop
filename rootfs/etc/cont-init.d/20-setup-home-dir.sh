#!/usr/bin/with-contenv sh

set -x # Show verbose output
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Set Environment variables
export HOME=/home/app

# Create home dir if not exists
HOME_CONFIG=/config/home/app
[ -d "$HOME_CONFIG" ] || mkdir -p $HOME_CONFIG

# Copy .bashrc to HOME
APP_BASHRC="$HOME/.bashrc"
[ -f "$APP_BASHRC" ] || cp /defaults/home/app/.bashrc $APP_BASHRC

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID $HOME_CONFIG

# Take ownership of the output directory.
if ! chown $USER_ID:$GROUP_ID $HOME_CONFIG; then
    # Failed to take ownership of $HOME_CONFIG.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w $HOME_CONFIG ]; then
        log "ERROR: Failed to take ownership and no write permission on $HOME_CONFIG."
        exit 1
    fi
fi