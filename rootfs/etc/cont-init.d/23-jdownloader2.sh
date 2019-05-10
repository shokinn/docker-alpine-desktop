#!/usr/bin/with-contenv sh

set -x # Show verbose output
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure mandatory directories exist.
mkdir -p /config/logs

if [ ! -f /config/JDownloader/JDownloader.jar ]; then
    mkdir -p /config/JDownloader
    cp /defaults/JDownloader/JDownloader.jar /config/JDownloader
    cp -r /defaults/JDownloader/cfg /config/JDownloader/
fi

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/logs
chown -R $USER_ID:$GROUP_ID /config/JDownloader

# Take ownership of the storage directory.
if ! chown $USER_ID:$GROUP_ID /storage; then
    # Failed to take ownership of /storage.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w /storage ]; then
        log "ERROR: Failed to take ownership and no write permission on /storage."
        exit 1
    fi
fi

# vim: set ft=sh :
