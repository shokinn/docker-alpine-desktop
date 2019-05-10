#!/usr/bin/with-contenv sh

set -x # Show verbose output
set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Copy xfce4 config
xfce_config_base_path='xdg/config/xfce4/xfconf/xfce-perchannel-xml'
[ -d "/config/$xfce_config_base_path/" ] || mkdir -p /config/$xfce_config_base_path/
[ -f "/config/$xfce_config_base_path/thunar.xml" ] || cp /defaults/$xfce_config_base_path/thunar.xml /config/$xfce_config_base_path/
[ -f "/config/$xfce_config_base_path/xfce4-desktop.xml" ] || cp /defaults/$xfce_config_base_path/xfce4-desktop.xml /config/$xfce_config_base_path/
[ -f "/config/$xfce_config_base_path/xfce4-panel.xml" ] || cp /defaults/$xfce_config_base_path/xfce4-panel.xml /config/$xfce_config_base_path/
[ -f "/config/$xfce_config_base_path/xsettings.xml" ] || cp /defaults/$xfce_config_base_path/xsettings.xml /config/$xfce_config_base_path/

# Copy xfce4 panel settings
xfce_panel_config_base_path='xdg/config/xfce4/panel'
[ -d "/config/$xfce_panel_config_base_path/" ] || mkdir -p /config/$xfce_panel_config_base_path/
[ "$(ls -A /config/$xfce_panel_config_base_path)" ] || find /defaults/$xfce_panel_config_base_path/ -mindepth 1 -maxdepth 1 -exec cp -r {} /config/$xfce_panel_config_base_path/ \;

# Copy thunar bookmarks
thunar_bookmarks_base_path='xdg/config/gtk-3.0'
[ -d "/config/$thunar_bookmarks_base_path/" ] || mkdir -p /config/$thunar_bookmarks_base_path/
[ -f "/config/$thunar_bookmarks_base_path/bookmarks" ] || cp /defaults/$thunar_bookmarks_base_path/bookmarks /config/$thunar_bookmarks_base_path/

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/xdg

# Take ownership of the output directory.
if ! chown $USER_ID:$GROUP_ID /config/xdg; then
    # Failed to take ownership of /config/xdg.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w /config/xdg ]; then
        log "ERROR: Failed to take ownership and no write permission on /config/xdg."
        exit 1
    fi
fi