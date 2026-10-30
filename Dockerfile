FROM ubuntu:24.04

LABEL org.opencontainers.image.title="Internet Radio Server"
LABEL org.opencontainers.image.description="Icecast + Liquidsoap + SHOUTcast"
LABEL org.opencontainers.image.version="1.0.0"

# ============================================================
# Base Configuration
# ============================================================

ENV DEBIAN_FRONTEND=noninteractive

# ============================================================
# Package Installation
# ============================================================

RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        wget \
        tar \
        gettext-base \
        supervisor \
        logrotate \
        ffmpeg \
        icecast2 \
        liquidsoap && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ============================================================
# SHOUTcast Installation
# ============================================================

ARG SHOUTCAST_URL=https://download.nullsoft.com/shoutcast/tools/sc_serv2_linux_x64-latest.tar.gz

RUN mkdir -p /tmp/shoutcast && \
    wget -O /tmp/shoutcast.tar.gz "${SHOUTCAST_URL}" && \
    tar -xzf /tmp/shoutcast.tar.gz -C /tmp/shoutcast && \
    find /tmp/shoutcast \
        -type f \
        -name sc_serv \
        -exec cp {} /usr/local/bin/sc_serv \; && \
    chmod 755 /usr/local/bin/sc_serv && \
    rm -rf /tmp/shoutcast /tmp/shoutcast.tar.gz

# Optional verification
RUN /usr/local/bin/sc_serv 2>&1 | head -5 || true

# ============================================================
# Application User
# ============================================================

RUN groupadd --system radio && \
    useradd \
        --system \
        --gid radio \
        --create-home \
        --home-dir /home/radio \
        radio

# ============================================================
# Directory Structure
# ============================================================

RUN mkdir -p \
        /config \
        /music \
        /logs \
        /defaults \
        /etc/icecast2 \
        /etc/shoutcast \
        /etc/liquidsoap \
        /var/log/icecast2 \
        /var/log/shoutcast \
        /var/log/liquidsoap

# ============================================================
# Default Templates
# These are copied to /config on first run if missing
# ============================================================

COPY templates/icecast.xml.template \
     /defaults/icecast.xml.template

COPY templates/sc_serv.conf.template \
     /defaults/sc_serv.conf.template

COPY templates/radio.liq.template \
     /defaults/radio.liq.template

COPY templates/users.txt \
     /defaults/users.txt

# ============================================================
# Runtime Files
# ============================================================

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY logrotate-radio /etc/logrotate.d/radio

RUN chmod 755 /entrypoint.sh

# ============================================================
# Default Environment Values
# ============================================================

ENV HOSTNAME=localhost \
    SOURCE_PW=ChangeMe123456! \
    RELAY_PW=ChangeMe123456! \
    ADMIN_USER=admin \
    ADMIN_PW=ChangeThisAdminPassword123! \
    SHOUTCAST_AUTH_HASH= \
    ICECAST_LOCATION=Unknown \
    ICECAST_ADMIN_EMAIL=admin@example.com \
    STATION_NAME="Internet Radio" \
    STATION_DESCRIPTION="24/7 Internet Radio Station" \
    STATION_GENRE="Various" \
    STATION_URL=https://example.com \
    ICECAST_PORT=8000 \
    SHOUTCAST_PORT=8001 \
    LIVE_PORT=8003 \
    TEST_PORT=8004 \
    BITRATE=320 \
    MAX_CLIENTS=1000 \
    MAX_SOURCES=10 \
    LOG_LEVEL=3 \
    MUSIC_DIR=/music

# ============================================================
# Volumes
# ============================================================

VOLUME ["/config"]
VOLUME ["/music"]
VOLUME ["/logs"]

# ============================================================
# Ownership
# ============================================================

RUN chown -R radio:radio \
    /config \
    /music \
    /logs \
    /defaults \
    /etc/icecast2 \
    /etc/shoutcast \
    /etc/liquidsoap \
    /var/log/icecast2 \
    /var/log/shoutcast \
    /var/log/liquidsoap

# ============================================================
# Network
# ============================================================

EXPOSE 8000
EXPOSE 8001
EXPOSE 8003
EXPOSE 8004

# ============================================================
# Health Check
# ============================================================

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --retries=3 \
    CMD bash -c '\
        pgrep icecast2 >/dev/null && \
        pgrep liquidsoap >/dev/null && \
        curl --fail --silent \
        http://127.0.0.1:${ICECAST_PORT}/status-json.xsl \
        >/dev/null \
    ' || exit 1

# ============================================================
# Runtime
# ============================================================

USER radio

STOPSIGNAL SIGTERM

ENTRYPOINT ["/entrypoint.sh"]
