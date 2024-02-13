# asterisk-docker

[![version)](https://img.shields.io/docker/v/crashvb/asterisk/latest)](https://hub.docker.com/repository/docker/crashvb/asterisk)
[![image size](https://img.shields.io/docker/image-size/crashvb/asterisk/latest)](https://hub.docker.com/repository/docker/crashvb/asterisk)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/asterisk-docker.svg)](https://github.com/crashvb/asterisk-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [Asterisk](https://www.asterisk.org/).

## Entrypoint Scripts

### asterisk

The embedded entrypoint script is located at `/etc/entrypoint.d/asterisk` and performs the following actions:

1. A new asterisk configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | ASTERISK\_CONF\_* | | The contents of `<asterisk_conf>/*.conf`. For example, `ASTERISK_CONFD_FOO` will create `<asterisk_conf>/foo.conf`.|

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ asterisk/
│  ├─ entrypoint.d/
│  │  └─ asterisk
│  ├─ healthcheck.d/
│  │  └─ asterisk
│  └─ supervisor/
│     └─ config.d/
│        └─ asterisk.conf
└─ var/
   └─ lib/
      └─ asterisk/
```

### Exposed Ports

* `5060/udp` - insecure SIP gateway.
* `5061/udp` - secure SIP gateway.
* `17700:17800/udp` - RTP ports.

### Volumes

* `/etc/asterisk` - asterisk configuration directory.
* `/usr/share/asterisk/sounds/en/custom` - asterisk custom sounds directory.
* `/var/lib/asterisk` - asterisk data directory.

## Development

[Source Control](https://github.com/crashvb/asterisk-docker)

