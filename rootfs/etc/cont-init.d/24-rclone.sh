#!/usr/bin/with-contenv sh

set -x # Show verbose output
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

set +u
[ -z "$RCLONE_CONFIG_FILE_NAME" ] && export RCLONE_CONFIG_FILE_NAME=rclone.conf
[ -z "$RCLONE_CONFIG_REMOTE" ] && export RCLONE_CONFIG_REMOTE=gdrive
[ -z "$RCLONE_CONFIG_REMOTE_PATH" ] && export RCLONE_CONFIG_REMOTE_PATH=""
set -u

# Create rclone config dir if not exists
RCLONE_CONFIG_DIR=/config/rclone
[ -d "$RCLONE_CONFIG_DIR" ] || mkdir -p $RCLONE_CONFIG_DIR
[ -d "$RCLONE_CONFIG_DIR" ] && chmod -R 770 $RCLONE_CONFIG_DIR

RCLONE_MOUNT_DIR=/gdrive
if [ -f "$RCLONE_CONFIG_DIR/${RCLONE_CONFIG_FILE_NAME}" ]; then
	[ -d "$RCLONE_MOUNT_DIR" ] || mkdir -p $RCLONE_MOUNT_DIR
	[ -d "$RCLONE_MOUNT_DIR" ] && chmod 400 $RCLONE_MOUNT_DIR
	rclone --config $RCLONE_CONFIG_DIR/${RCLONE_CONFIG_FILE_NAME} \
	mount ${RCLONE_CONFIG_REMOTE}:${RCLONE_CONFIG_REMOTE_PATH} $RCLONE_MOUNT_DIR \
	--daemon --default-permissions --uid $USER_ID --gid $GROUP_ID --allow-other &
fi