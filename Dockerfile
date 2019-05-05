# Set base image
FROM jlesage/baseimage-gui:alpine-3.9

# Define working directory.
WORKDIR /tmp

# Install packages
RUN \
	apk --no-cache add \
		xorg-server \
		xf86-input-libinput \
		eudev