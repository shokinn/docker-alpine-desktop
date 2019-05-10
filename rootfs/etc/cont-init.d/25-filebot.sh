#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure mandatory directories exist.
mkdir -p /config/logs

FILEBOT_CFG_PATH=/config/filebot
[ -d "$FILEBOT_CFG_PATH" ] || mkdir -p $FILEBOT_CFG_PATH
[ -d "$FILEBOT_CFG_PATH" ] && chown $USER_ID:$GROUP_ID $FILEBOT_CFG_PATH
LICENSE_PATH=$FILEBOT_CFG_PATH/license.psm

# Copy default config.
if [ ! -f $FILEBOT_CFG_PATH/prefs.properties ]; then
    cp /defaults/filebot/prefs.properties $FILEBOT_CFG_PATH/
fi

# Install the license to the proper location.
if [ ! -f "$LICENSE_PATH" ]; then
    LFILE="$(find $FILEBOT_CFG_PATH -maxdepth 1 -name "*.psm" -type f)"
    if [ "${LFILE:-UNSET}" != "UNSET" ]; then
        LFILE_COUNT="$(echo "$LFILE" | wc -l)"
        if [ "$LFILE_COUNT" -eq 1 ]; then
            log "installing license file $(basename "$LFILE")..."
            mv "$LFILE" "$LICENSE_PATH"
        else
            log "multiple license files found: skipping installation"
        fi
    fi
fi

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/logs
find $FILEBOT_CFG_PATH -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# Make filebot startup script executable
chmod 775 /opt/filebot/filebot

# vim: set ft=sh :
