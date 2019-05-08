#!/bin/sh
# -x	Print a trace of simple commands and their arguments
#		after they are expanded and before they are executed. -o xtrace
# -e	Exit immediately if a simple command exits with a non-zero status, unless
#		the command that fails is part of an until or  while loop, part of an
#		if statement, part of a && or || list, or if the command's return status
#		is being inverted using !.  -o errexit
# -f	Disable file name generation (globbing).  -o noglob
# -u	Treat unset variables as an error when performing 
#		parameter expansion. An error message will be written 
#		to the standard error, and a non-interactive shell will exit. -o nounset
set -xefu

# Set Environment variables
export HOME=/home/app

# Copy xfce4 config
set +f
xfce_config_base_path='xdg/config/xfce4/xfconf/xfce-perchannel-xml'
mkdir -p /config/$xfce_config_base_path/
[ -f "/config/$xfce_config_base_path/xsettings.xml" ] || cp -r /opt/$xfce_config_base_path/* /config/$xfce_config_base_path/
set -f

# Disable that unset variables are treated as an error.
set +u

# fix broken $UID on some system...
if test "x$UID" = "x"; then
  if test -x /usr/xpg4/bin/id; then
    UID=`/usr/xpg4/bin/id -u`;
  else
    UID=`id -u`;
  fi
fi

# set $XDG_MENU_PREFIX to "xfce-" so that "xfce-applications.menu" is picked
# over "applications.menu" in all Xfce applications.
if test "x$XDG_MENU_PREFIX" = "x"; then
  XDG_MENU_PREFIX="xfce-"
  export XDG_MENU_PREFIX
fi

# set DESKTOP_SESSION so that one can detect easily if an Xfce session is running
if test "x$DESKTOP_SESSION" = "x"; then
  DESKTOP_SESSION="xfce"
  export DESKTOP_SESSION
fi

# set XDG_CURRENT_DESKTOP so that Qt 5 applications can identify user set Xfce theme
if test "x$XDG_CURRENT_DESKTOP" = "x"; then
  XDG_CURRENT_DESKTOP="XFCE"
  export XDG_CURRENT_DESKTOP
fi

# $XDG_CONFIG_HOME defines the base directory relative to which user specific
# configuration files should be stored. If $XDG_CONFIG_HOME is either not set
# or empty, a default equal to $HOME/.config should be used.
echo $HOME
if test "x$XDG_CONFIG_HOME" = "x" ; then
  XDG_CONFIG_HOME=$HOME/.config
fi
[ -d "$XDG_CONFIG_HOME" ] || mkdir -p "$XDG_CONFIG_HOME"

# $XDG_CACHE_HOME defines the base directory relative to which user specific
# non-essential data files should be stored. If $XDG_CACHE_HOME is either not
# set or empty, a default equal to $HOME/.cache should be used.
if test "x$XDG_CACHE_HOME" = "x" ; then
  XDG_CACHE_HOME=$HOME/.cache
fi
[ -d "$XDG_CACHE_HOME" ] || mkdir "$XDG_CACHE_HOME"

# set up XDG user directores.  see
# http://freedesktop.org/wiki/Software/xdg-user-dirs
if which xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update
fi

# Modify libglade and glade environment variables so that
# it will find the files installed by Xfce
GLADE_CATALOG_PATH="$GLADE_CATALOG_PATH:"
GLADE_PIXMAP_PATH="$GLADE_PIXMAP_PATH:"
GLADE_MODULE_PATH="$GLADE_MODULE_PATH:"
export GLADE_CATALOG_PATH
export GLADE_PIXMAP_PATH
export GLADE_MODULE_PATH

# For now, start with an empty list
XRESOURCES=""

# Has to go prior to merging Xft.xrdb, as its the "Defaults" file
test -r "/etc/xdg/xfce4/Xft.xrdb" && XRESOURCES="$XRESOURCES /etc/xdg/xfce4/Xft.xrdb"
test -r $HOME/.Xdefaults && XRESOURCES="$XRESOURCES $HOME/.Xdefaults"

BASEDIR=$XDG_CONFIG_HOME/xfce4
if test -r "$BASEDIR/Xft.xrdb"; then
  XRESOURCES="$XRESOURCES $BASEDIR/Xft.xrdb"
elif test -r "$XFCE4HOME/Xft.xrdb"; then
  mkdir -p "$BASEDIR"
  cp "$XFCE4HOME/Xft.xrdb" "$BASEDIR"/
  XRESOURCES="$XRESOURCES $BASEDIR/Xft.xrdb"
fi

# merge in X cursor settings
test -r "$BASEDIR/Xcursor.xrdb" && XRESOURCES="$XRESOURCES $BASEDIR/Xcursor.xrdb"

# ~/.Xresources contains overrides to the above
test -r "$HOME/.Xresources" && XRESOURCES="$XRESOURCES $HOME/.Xresources"

# load all X resources (adds /dev/null to avoid an empty list that would hang the process)
cat /dev/null $XRESOURCES | xrdb -merge -

# load local modmap
test -r $HOME/.Xmodmap && xmodmap $HOME/.Xmodmap

##################
# IMPORTANT NOTE #
##################

# Everything below here ONLY gets executed if you are NOT using xfce4-session
# (Xfce's session manager).  If you are using the session manager, everything
# below is handled by it, and the code below is not executed at all.  If you're
# not sure if you're using the session manager, type 'ps -e|grep xfce4-session'
# in a terminal while Xfce is running.

##################

# Use dbus-launch if installed.
if test x"$DBUS_SESSION_BUS_ADDRESS" = x""; then
  if which dbus-launch >/dev/null 2>&1; then
    eval `dbus-launch --sh-syntax --exit-with-session`
    # some older versions of dbus don't export the var properly
    export DBUS_SESSION_BUS_ADDRESS
  else
    echo "Could not find dbus-launch; Xfce will not work properly" >&2
    fi
fi

# this is only necessary when running w/o xfce4-session
xsetroot -solid black -cursor_name watch

# or use old-fashioned startup script otherwise

xfsettingsd &
# this images uses openbox instead of xf4wm
#xfwm4 --daemon

# start up stuff in $XDG_CONFIG_HOME/autostart/
if test -d "$XDG_CONFIG_HOME/autostart"; then
  for i in ${XDG_CONFIG_HOME}/autostart/*.desktop; do
    grep -q -E "^Hidden=true" "$i" && continue
    if grep -q -E "^OnlyShowIn=" "$i"; then
      # need to test twice, as lack of the line entirely means we still run it
      grep -E "^OnlyShowIn=" "$i" | grep -q 'XFCE;' || continue
    fi
    grep -E "^NotShowIn=" "$i" | grep -q 'XFCE;' && continue

    # check for TryExec
    trycmd=`grep -E "^TryExec=" "$i" | cut -d'=' -f2`
    if test "$trycmd"; then
      which "$trycmd" >/dev/null 2>&1 || continue
    fi

    cmd=`grep -E "^Exec=" "$i" | cut -d'=' -f2`
    if test "$cmd" && which "$cmd" >/dev/null 2>&1; then
      $cmd &
    fi
  done
fi

xfdesktop &

# # Set Wallpaper
# sleep 5
# xfconf-query -c xfce4-desktop \
#   -p /backdrop/screen0/monitorscreen/workspace0/last-image \
#   -s "/usr/share/backgrounds/android_5_lollipop.jpg"

# # Set Icon Theme
# xfconf-query -c xsettings \
#   -p /Net/IconThemeName \
#   -s "Flat-Remix-Green-Dark"

# # Set Theme
# xfconf-query -c xsettings \
#   -p /Net/ThemeName \
#   -s "PRO-dark-XFCE-edition II"

panel=`which xfce4-panel`
case "x$panel" in
	x|xno*)
		;;
	*)
		$panel
		ret=$?
		while test $ret -ne 0; do
			xmessage -center -file - -timeout 20 -title Error <<EOF
A crash occured in the panel
Please report this to the xfce4-dev@xfce.org list
or on http://bugs.xfce.org
Meanwhile the panel will be restarted
EOF
			cat >&2 <<EOF
A crash occured in the panel
Please report this to the xfce4-dev@xfce.org list
or on http://bugs.xfce.org
Meanwhile the panel will be restarted
EOF
			$panel
			ret=$?
		done
		;;
esac

xsetroot -bg white -fg red  -solid black -cursor_name watch
