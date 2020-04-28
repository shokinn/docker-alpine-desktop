# Set base image
# https://github.com/jlesage/docker-baseimage-gui
FROM jlesage/baseimage-gui:alpine-3.10-glibc

# Define software versions.
# Alpine version
ARG ALPINE_VERSION=3.10
# https://github.com/avih/dejsonlz4 -- commit id is version
ARG JSONLZ4_VERSION=c4305b8
# https://github.com/lz4/lz4/releases -- tag is version
ARG LZ4_VERSION=1.9.2
# https://docs.aws.amazon.com/de_de/corretto/latest/corretto-8-ug/downloads-list.html
ARG JAVAJRE_VERSION=8.212.04.2
# https://rclone.org/downloads/
ARG RCLONE_VERSION=1.51.0
ARG RCLONE_ARCH=amd64
# https://www.filebot.net/#download
ARG FILEBOT_VERSION=4.9.1
# OpenJFX
ARG OPENJFX_VERSION=8.151.12-r0
# https://github.com/acoustid/chromaprint
ARG CHROMAPRINT_VERSION=1.4.3

# Define software download URLs.
ARG JSONLZ4_URL=https://github.com/avih/dejsonlz4/archive/${JSONLZ4_VERSION}.tar.gz
ARG LZ4_URL=https://github.com/lz4/lz4/archive/v${LZ4_VERSION}.tar.gz
ARG JDOWNLOADER_URL=http://installer.jdownloader.org/JDownloader.jar
ARG JAVAJRE_URL=https://d3pxv6yz143wms.cloudfront.net/${JAVAJRE_VERSION}/amazon-corretto-${JAVAJRE_VERSION}-linux-x64.tar.gz
ARG RCLONE_URL=https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${RCLONE_ARCH}.zip
ARG FILEBOT_URL=https://get.filebot.net/filebot/FileBot_${FILEBOT_VERSION}/FileBot_${FILEBOT_VERSION}-portable-jdk8.tar.xz
ARG OPENJFX_URL=https://github.com/sgerrand/alpine-pkg-java-openjfx/releases/download/${OPENJFX_VERSION}/java-openjfx-${OPENJFX_VERSION}.apk
ARG CHROMAPRINT_URL=https://github.com/acoustid/chromaprint/archive/v${CHROMAPRINT_VERSION}.tar.gz


# Define working directory.
WORKDIR /tmp

# Add Repos permanently
RUN \
	echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
	echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# Upgrade current packages
RUN \
	apk --update --no-cache upgrade

# Generate and install favicons.
RUN \
	APP_ICON_URL=https://github.com/xfce-mirror/xfdesktop/raw/master/pixmaps/xfce4_xicon1.png \
	&& install_app_icon.sh "$APP_ICON_URL"

# Install console packages
RUN \
	apk --no-cache add \
		bash \
		bash-completion \
		bash-doc \
		ca-certificates \
		curl \
		dbus \
		dbus-x11 \
		eudev \
		ffmpeg \
		ffmpeg-libs \
		fuse \
		git \
		htop \
		java-jna \
		libgcc \
		libmediainfo \
		libstdc++ \
		man \
		man-pages \
		mc \
		mdocml-apropos \
		nano \
		nss \
		openjdk8-jre \
		p7zip \
		p7zip-doc \
		python3 \
		rsync \
		rtmpdump \
		screen \
		sudo \
		tar \
		tar-doc \
		tmux \
		unrar \
		unzip \
		util-linux \
		vim \
		wget \
		xz \
		xz-doc \
		zip \
	&& update-ca-certificates

# TODO
# Install pip / pipsi

# Install XFCE4
RUN \
	apk --no-cache add \
		desktop-file-utils \
		exo \
		garcon \
		gtk+2.0 \
		libxfce4ui \
		libxfce4util \
		thunar \
		thunar-archive-plugin \
		ttf-dejavu \
		ttf-freefont \
		xarchiver \
		xdotool \
		xfce4-appfinder \
		xfce4-panel \
		xfce4-settings \
		xfce4-terminal \
		xfconf \
		xfdesktop \
		xterm \
		yad

# Install Flat Icon theme
RUN \
	git clone https://github.com/daniruiz/flat-remix \
	&& mkdir -p /usr/share/icons/ \
	&& rsync -av --progress flat-remix/Flat-Remix-Green-Dark /usr/share/icons/ \
	&& gtk-update-icon-cache /usr/share/icons/Flat-Remix-Green-Dark/ \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

# Install PRO Dark XFCE theme
RUN \
	git clone https://github.com/paullinuxthemer/PRO-Dark-XFCE-Edition.git \
	&& mkdir -p /usr/share/themes/ \
	&& rsync -av --progress 'PRO-Dark-XFCE-Edition/PRO-dark-XFCE-edition II' /usr/share/themes/ \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

# Install X Pakcages
RUN \
	apk --no-cache add \
		chromium \
		filezilla \
		firefox-esr 

## Firefox
### TODO - Firefox plugins

## JDownloader 2
### Download JDownloader 2.
RUN \
	mkdir -p /defaults/JDownloader/ && \
	wget ${JDOWNLOADER_URL} -O /defaults/JDownloader/JDownloader.jar

### Download and install Oracle JRE.
### NOTE: This is needed only for the 7-Zip-JBinding workaround.
RUN \
	mkdir /opt/jre \
	&& curl -# -L ${JAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre amazon-corretto-${JAVAJRE_VERSION}-linux-x64/jre

## rclone
### Install rclone
RUN \
	curl -O ${RCLONE_URL} \
	&& unzip rclone-v${RCLONE_VERSION}-linux-${RCLONE_ARCH}.zip \
	&& cd rclone-v${RCLONE_VERSION}-linux-${RCLONE_ARCH} \
	&& sudo cp rclone /usr/bin/ \
	&& sudo chown root:root /usr/bin/rclone \
	&& sudo chmod 755 /usr/bin/rclone \
	&& sudo mkdir -p /usr/share/man/man1 \
	&& sudo cp rclone.1 /usr/share/man/man1/ \
	&& sudo makewhatis /usr/share/man \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

## Filebot
### Install FileBot.
RUN \
	mkdir filebot \
	# Download sources.
	&& curl -# -L ${FILEBOT_URL} | tar -xJf- -C filebot \
	#&& tar xJ -C filebot FileBot_${FILEBOT_VERSION}-portable.tar.xz \
	# Install.
	&& mkdir /opt/filebot \
	&& cp -Rv filebot/jar /opt/filebot/ \
	&& wget https://www.filebot.net/images/filebot.logo.svg -O /opt/filebot/filebot.svg \
	# Cleanup.
	&& rm -rf /tmp/* /tmp/.[!.]*

### Install Filebot dependencies.
RUN \
	curl -# -L -o java-openjfx.apk ${OPENJFX_URL} \
	&& apk --no-cache add --allow-untrusted ./java-openjfx.apk


### Build and install chromaprint (fpcalc) for AcousItD.
RUN \
	add-pkg --virtual build-dependencies \
		build-base \
		cmake \
		ffmpeg-dev \
		fftw-dev \
	# Download.
	&& mkdir chromaprint \
	&& curl -# -L ${CHROMAPRINT_URL} | tar xz --strip 1 -C chromaprint \
	# Compile.
	&& cd chromaprint \
	&& mkdir build \
	&& cd build \
	&& cmake \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_BUILD_TYPE=Release \
		-DBUILD_TOOLS=ON \
		.. \
	&& make -j$(nproc) \
	&& make install \
	&& cd .. \
	&& cd .. \
	# Cleanup.
	&& del-pkg build-dependencies \
	&& rm -rf /usr/include \
			/usr/lib/pkgconfig \
	&& rm -rf /tmp/* /tmp/.[!.]*


# Add files.
COPY rootfs/ /

# Add home dir for "app" user
# Add "app" user to sudoers file
RUN \
	ln -s /config/home/app /home/app \
	&& echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set environment variables
ENV APP_NAME="xfce4" \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	TERM=xfce4-terminal \
	SHELL=/bin/bash

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Expose ports.
#   - 3129: For MyJDownloader in Direct Connection mode.
EXPOSE 3129

# Metadata.
LABEL \
	org.label-schema.name="xfce4" \
	org.label-schema.description="Docker container for XFCE4 desktop with openbox as window manager" \
	org.label-schema.version="unknown" \
	org.label-schema.vcs-url="https://github.com/shokinn/docker-alpine-desktop" \
	org.label-schema.schema-version="1.0" \
	maintainer="Philip Henning <mail@philip-henning.com>"
