FROM crashvb/supervisord:202303031721@sha256:6ff97eeb4fbabda4238c8182076fdbd8302f4df15174216c8f9483f70f163b68 as builder

# Install packages, download files ...
COPY asterisk-build /usr/bin/
RUN docker-apt build-essential git libedit-dev libjansson-dev libncurses-dev libresample-dev libsqlite3-dev libssl-dev libxml2-dev subversion uuid-dev && \
	/usr/bin/asterisk-build && \
	rm --recursive /build/var/run

FROM crashvb/supervisord:202303031721@sha256:6ff97eeb4fbabda4238c8182076fdbd8302f4df15174216c8f9483f70f163b68
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:6ff97eeb4fbabda4238c8182076fdbd8302f4df15174216c8f9483f70f163b68" \
	org.opencontainers.image.base.name="crashvb/supervisord:202303031721" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing asterisk." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/asterisk-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/asterisk" \
	org.opencontainers.image.url="https://github.com/crashvb/asterisk-docker"

# Install packages, download files ...
COPY --from=builder /build /
RUN docker-apt libedit2 libjansson4 libresample1 libsqlite3-0 libssl3 libxml2 uuid-runtime

# Configure: asterisk
# https://salsa.debian.org/pkg-voip-team/asterisk/-/blob/debian/latest/debian/asterisk.postinst
ENV ASTERISK_CONFIG=/etc/asterisk ASTERISK_DATA=/var/lib/asterisk ASTERISK_GID=700 ASTERISK_GNAME=asterisk ASTERISK_MAX_CALLS=25 ASTERISK_SOUNDS=/usr/share/asterisk/sounds ASTERISK_UID=700 ASTERISK_UNAME=asterisk
RUN groupadd --gid=${ASTERISK_GID} ${ASTERISK_GNAME} && \
	useradd --gid=${ASTERISK_GID} --groups audio,dialout --home-dir=${ASTERISK_DATA} --no-create-home --shell=/usr/sbin/nologin --uid=${ASTERISK_UID} ${ASTERISK_UNAME} && \
	chown --recursive ${ASTERISK_UID}:${ASTERISK_GID} ${ASTERISK_CONFIG} ${ASTERISK_DATA} /var/log/asterisk /var/spool/asterisk && \
	install --directory --group=root --mode=0775 /usr/local/share/asterisk/sounds /usr/local/share/asterisk.template && \
	cp --preserve ${ASTERISK_CONFIG}/asterisk.conf ${ASTERISK_CONFIG}/asterisk.conf.dist && \
	mv ${ASTERISK_CONFIG} /usr/local/share/asterisk.template/config && \
	mv ${ASTERISK_DATA} /usr/local/share/asterisk.template/data && \
	mv ${ASTERISK_SOUNDS} /usr/local/share/asterisk.template/sounds

# Configure: supervisor
COPY supervisord.asterisk.conf /etc/supervisor/conf.d/asterisk.conf

# Configure: entrypoint
RUN touch /usr/local/share/asterisk.template/data/placeholder
COPY entrypoint.asterisk /etc/entrypoint.d/asterisk

# Configure: healthcheck
COPY healthcheck.asterisk /etc/healthcheck.d/asterisk

EXPOSE 5060/udp 5061/udp 17700-17710/udp

VOLUME ${ASTERISK_CONFIG} ${ASTERISK_DATA} ${ASTERISK_SOUNDS}
