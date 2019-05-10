#!/usr/bin/with-contenv sh

set -x # Show verbose output
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Set root shell to /bin/bash
usermod --shell /bin/bash root