# DEPRECATION NOTICE
> [!warning]
> This repository is deprecated and won't be updated anymore!

# docker-alpine-desktop
A desktop envirunment based on alpine and xfce4 wich runs in a docker container with a WEB VNC

[![Docker Automated build](https://img.shields.io/docker/automated/shokinn/docker-alpine-desktop.svg)](https://hub.docker.com/r/shokinn/docker-alpine-desktop/)
[![Docker image version](https://images.microbadger.com/badges/version/shokinn/docker-alpine-desktop.svg)](https://microbadger.com/images/shokinn/docker-alpine-desktop)
[![Docker image size](https://images.microbadger.com/badges/image/shokinn/docker-alpine-desktop.svg)](https://microbadger.com/images/shokinn/docker-alpine-desktop)

You can invite me to a beer if you want ;)


This is a completely funcional Docker image with a xfce4 desktop environment.

Based on Alpine Linux, which provides a very small size. 

Tested and working on x86_64 devices.

Thanks to [@jlesage](https://github.com/jlesage/) for a great base image for GUI apps.

Instructions: 
- Map any local port to 5800 for web access
- Map any local port to 5900 for VNC access
- Map a local volume to /config (Stores configuration data)
- Map a local volume to /shared (Access media files)

Sample run command:

```bash
docker run -d --name=alpine-desktop \
-v /share/Container/alpine-desktop/config:/config \
-v /share/Container/alpine-desktop/media:/media \
-e GROUP_ID=1000 \
-e USER_ID=1000 \
-e TZ=Europe/Berlin \
-e RCLONE_CONFIG_REMOTE=plexdrive_crypt \
--cap-add SYS_ADMIN \
--device /dev/fuse \
--shm-size 2g \
-p 5800:5800 \
-p 5900:5900 \
shokinn/docker-alpine-desktop:latest
```

docker run --rm -p 5800:5800 -p 5900:5900 -v /Users/phg/Downloads/config:/config -e RCLONE_CONFIG_REMOTE=plexdrive_crypt --cap-add SYS_ADMIN --device /dev/fuse docker-alpine-desktop:latest

Browse to `http://your-host-ip:5800` to access the alpine-desktop GUI.

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable                    | Description                                                                                                                                                                                                                                                                                                                                                                                 | Default       |
|:----------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:--------------|
| `USER_ID`                   | ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set.                                                                                                                                                                                                                                                                 | `1000`        |
| `GROUP_ID`                  | ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set.                                                                                                                                                                                                                                                                | `1000`        |
| `SUP_GROUP_IDS`             | Comma-separated list of supplementary group IDs of the application.                                                                                                                                                                                                                                                                                                                         | (unset)       |
| `UMASK`                     | Mask that controls how file permissions are set for newly created files. The value of the mask is in octal notation.  By default, this variable is not set and the default umask of `022` is used, meaning that newly created files are readable by everyone, but only writable by the owner. See the following online umask calculator: http://wintelguy.com/umask-calc.pl                 | (unset)       |
| `TZ`                        | [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container.                                                                                                                                                                                                                                                                      | `Etc/UTC`     |
| `KEEP_APP_RUNNING`          | When set to `1`, the application will be automatically restarted if it crashes or if user quits it.                                                                                                                                                                                                                                                                                         | `0`           |
| `APP_NICENESS`              | Priority at which the application should run.  A niceness value of -20 is the highest priority and 19 is the lowest priority.  By default, niceness is not set, meaning that the default niceness of 0 is used.  **NOTE**: A negative niceness (priority increase) requires additional permissions.  In this case, the container should be run with the docker option `--cap-add=SYS_NICE`. | (unset)       |
| `CLEAN_TMP_DIR`             | When set to `1`, all files in the `/tmp` directory are delete during the container startup.                                                                                                                                                                                                                                                                                                 | `1`           |
| `DISPLAY_WIDTH`             | Width (in pixels) of the application's window.                                                                                                                                                                                                                                                                                                                                              | `1280`        |
| `DISPLAY_HEIGHT`            | Height (in pixels) of the application's window.                                                                                                                                                                                                                                                                                                                                             | `768`         |
| `SECURE_CONNECTION`         | When set to `1`, an encrypted connection is used to access the application's GUI (either via web browser or VNC client).  See the [Security](#security) section for more details.                                                                                                                                                                                                           | `0`           |
| `VNC_PASSWORD`              | Password needed to connect to the application's GUI.  See the [VNC Password](#vnc-password) section for more details.                                                                                                                                                                                                                                                                       | (unset)       |
| `X11VNC_EXTRA_OPTS`         | Extra options to pass to the x11vnc server running in the Docker container.  **WARNING**: For advanced users. Do not use unless you know what you are doing.                                                                                                                                                                                                                                | (unset)       |
| `ENABLE_CJK_FONT`           | When set to `1`, open source computer font `WenQuanYi Zen Hei` is installed.  This font contains a large range of Chinese/Japanese/Korean characters.                                                                                                                                                                                                                                       | `0`           |
| `RCLONE_CONFIG_FILE_NAME`   | File name of the rclone config which have to be placed in `/config/rclone/`.                                                                                                                                                                                                                                                                                                                | `rclone.conf` |
| `RCLONE_CONFIG_REMOTE`      | Remote name in the rclong config file which should be mounted.                                                                                                                                                                                                                                                                                                                              | `gdrive`      |
| `RCLONE_CONFIG_REMOTE_PATH` | \[Optional\] Path in the remote which should be mounted as base path.                                                                                                                                                                                                                                                                                                                       | `""`          |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path | Permissions | Description                                                                                    |
|:---------------|:------------|:-----------------------------------------------------------------------------------------------|
| `/config`      | rw          | This is where the application stores its configuration, log and any files needing persistency. |
| `/storage`     | rw          | This is where downloaded files are stored, or where you put files in your host for uploading.  |

### Ports

Here is the list of ports used by the container.  They can be mapped to the host
via the `-p` parameter (one per port mapping).  Each mapping is defined in the
following format: `<HOST_PORT>:<CONTAINER_PORT>`.  The port number inside the
container cannot be changed, but you are free to use any port on the host side.

| Port | Mapping to host | Description                                                                                         |
|:-----|:----------------|:----------------------------------------------------------------------------------------------------|
| 5800 | Mandatory       | Port used to access the application's GUI via the web interface.                                    |
| 5900 | Optional        | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |

## User/Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USER_ID` and `GROUP_ID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Security

By default, access to the application's GUI is done over an unencrypted
connection (HTTP or VNC).

Secure connection can be enabled via the `SECURE_CONNECTION` environment
variable.  See the [Environment Variables](#environment-variables) section for
more details on how to set an environment variable.

When enabled, application's GUI is performed over an HTTPs connection when
accessed with a browser.  All HTTP accesses are automatically redirected to
HTTPs.

When using a VNC client, the VNC connection is performed over SSL.  Note that
few VNC clients support this method.  [SSVNC] is one of them.

[SSVNC]: http://www.karlrunge.com/x11vnc/ssvnc.html

### Certificates

Here are the certificate files needed by the container.  By default, when they
are missing, self-signed certificates are generated and used.  All files have
PEM encoded, x509 certificates.

| Container Path                    | Purpose                      | Content                                                                                        |
|:----------------------------------|:-----------------------------|:-----------------------------------------------------------------------------------------------|
| `/config/certs/vnc-server.pem`    | VNC connection encryption.   | VNC server's private key and certificate, bundled with any root and intermediate certificates. |
| `/config/certs/web-privkey.pem`   | HTTPs connection encryption. | Web server's private key.                                                                      |
| `/config/certs/web-fullchain.pem` | HTTPs connection encryption. | Web server's certificate, bundled with any root and intermediate certificates.                 |

**NOTE**: To prevent any certificate validity warnings/errors from the browser
or VNC client, make sure to supply your own valid certificates.

**NOTE**: Certificate files are monitored and relevant daemons are automatically
restarted when changes are detected.

### VNC Password

To restrict access to your application, a password can be specified.  This can
be done via two methods:
  * By using the `VNC_PASSWORD` environment variable.
  * By creating a `.vncpass_clear` file at the root of the `/config` volume.
    This file should contains the password in clear-text.  During the container
    startup, content of the file is obfuscated and moved to `.vncpass`.

The level of security provided by the VNC password depends on two things:
  * The type of communication channel (encrypted/unencrypted).
  * How secure access to the host is.

When using a VNC password, it is highly desirable to enable the secure
connection to prevent sending the password in clear over an unencrypted channel.

**ATTENTION**: Password is limited to 8 characters.  This limitation comes from
the Remote Framebuffer Protocol [RFC](https://tools.ietf.org/html/rfc6143) (see
section [7.2.2](https://tools.ietf.org/html/rfc6143#section-7.2.2)).  Any
characters beyhond the limit are ignored.

## Shell Access

To get shell access to a the running container, execute the following command:

```
docker exec -ti CONTAINER sh
```

Where `CONTAINER` is the ID or the name of the container used during its
creation (e.g. `alpine-desktop`).

## Reverse Proxy

The following sections contains NGINX configuration that need to be added in
order to reverse proxy to this container.

A reverse proxy server can route HTTP requests based on the hostname or the URL
path.

### Routing Based on Hostname

In this scenario, each hostname is routed to a different application/container.

For example, let's say the reverse proxy server is running on the same machine
as this container.  The server would proxy all HTTP requests sent to
`alpine-desktop.domain.tld` to the container at `127.0.0.1:5800`.

Here are the relevant configuration elements that would be added to the NGINX
configuration:

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream alpine-desktop {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	server_name alpine-desktop.domain.tld;

	location / {
	        proxy_pass http://alpine-desktop;
	}

	location /websockify {
		proxy_pass http://alpine-desktop;
		proxy_http_version 1.1;
		proxy_set_header Upgrade $http_upgrade;
		proxy_set_header Connection $connection_upgrade;
		proxy_read_timeout 86400;
	}
}

```

### Routing Based on URL Path

In this scenario, the hostname is the same, but different URL paths are used to
route to different applications/containers.

For example, let's say the reverse proxy server is running on the same machine
as this container.  The server would proxy all HTTP requests for
`server.domain.tld/alpine-desktop` to the container at `127.0.0.1:5800`.

Here are the relevant configuration elements that would be added to the NGINX
configuration:

```
map $http_upgrade $connection_upgrade {
	default upgrade;
	''      close;
}

upstream alpine-desktop {
	# If the reverse proxy server is not running on the same machine as the
	# Docker container, use the IP of the Docker host here.
	# Make sure to adjust the port according to how port 5800 of the
	# container has been mapped on the host.
	server 127.0.0.1:5800;
}

server {
	[...]

	location = /alpine-desktop {return 301 $scheme://$http_host/alpine-desktop/;}
	location /alpine-desktop/ {
		proxy_pass http://alpine-desktop/;
		location /alpine-desktop/websockify {
			proxy_pass http://alpine-desktop/websockify/;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $connection_upgrade;
			proxy_read_timeout 86400;
		}
	}
}

```

[TimeZone]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].
