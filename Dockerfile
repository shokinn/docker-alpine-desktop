# Set base image
FROM jlesage/baseimage-gui:alpine-3.9

# Metadata.
LABEL \
	org.label-schema.name="xfce4" \
	org.label-schema.description="Docker container for XFCE4 desktop with openbox as window manager" \
	org.label-schema.version="unknown" \
	org.label-schema.vcs-url="https://github.com/shokinn/docker-alpine-desktop" \
	org.label-schema.schema-version="1.0" \
	maintainer="Philip Henning <mail@philip-henning.com>"

# Define working directory.
WORKDIR /tmp

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://github.com/xfce-mirror/xfdesktop/raw/master/pixmaps/xfce4_xicon1.png \
    && install_app_icon.sh "$APP_ICON_URL"

# Add Repos permanently
RUN \
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Upgrade current packages
RUN \
	apk --update --no-cache upgrade

# Install console packages
RUN \
	apk --no-cache add \
		man \
		man-pages \
		dbus \
		dbus-x11 \
		eudev \
		ca-certificates \
		bash \
		python3 \
		sudo \
		vim \
		nano \
		mc \
		git \
		util-linux \
		wget \
		curl \
		tmux \
		screen \
		htop \
		tar \
		zip \
		unzip \
		unrar \
		p7zip \
		p7zip-doc \
		rsync \
	&& update-ca-certificates

# TODO
# Install pip / pipsi

# Install XFCE4
RUN \
	apk --no-cache add \
		exo \
		garcon \
		libxfce4ui \
		libxfce4util \
		thunar \
		xfce4-appfinder \
		xfce4-mixer \
		xfce4-panel \
		xfce4-power-manager \
		xfce4-settings \
		xfce4-terminal \
		xfconf \
		xfdesktop \
		xfce4-terminal \
		xdotool \
		ttf-dejavu \
		ttf-freefont
		# adwaita-icon-theme \
		# tango-icon-theme \
		# gnome-icon-theme \
		# faenza-icon-theme \
		# mate-icon-theme

# Install Flat Icon theme
RUN \
	git clone https://github.com/daniruiz/flat-remix \
	&& mkdir -p /usr/share/icons/ \
	&& rsync -av --progress flat-remix/Flat-Remix-Green-Dark /usr/share/icons/ \
	&& gtk-update-icon-cache /usr/share/icons/Flat-Remix-Green-Dark/

# Install PRO Dark XFCE theme
RUN \
	git clone https://github.com/paullinuxthemer/PRO-Dark-XFCE-Edition.git \
	&& mkdir -p /usr/share/themes/ \
	&& rsync -av --progress 'PRO-Dark-XFCE-Edition/PRO-dark-XFCE-edition II' /usr/share/themes/

# Install X Pakcages
RUN \
	apk --no-cache add \
		firefox \
		chromium

# Add files.
COPY rootfs/ /

# Add home dir for "app" user
# Add "app" user to sudoers file
RUN \
	mkdir -p /home/app \
	&& chown -R 1000:1000 /home/app \
	&& chmod 750 /home/app \
	&& echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set environment variables
ENV APP_NAME="xfce4" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    TERM=xfce4-terminal \
    SHELL=/bin/bash
