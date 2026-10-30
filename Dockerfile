FROM ubuntu:24.04

LABEL maintainer="Dave"
LABEL description="Icecast + Liquidsoap + SHOUTcast DNAS"

ENV DEBIAN_FRONTEND=noninteractive

# =====================================================================
# Install packages
# =====================================================================

RUN apt-get update && apt-get install -y \
    icecast2 \
    liquidsoap \
    ffmpeg \
    supervisor \
    gettext-base \
    curl \
    wget \
    tar \
    logrotate \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =====================================================================
# Install SHOUTcast DNAS
# =====================================================================

ARG SHOUTCAST_URL=https://download.nullsoft.com/shoutcast/tools/sc_serv2_linux_x64-latest.tar.gz

RUN mkdir -p /tmp/shoutcast && \
    wget -O /tmp/shoutcast.tar.gz "${SHOUTCAST_URL}" && \
    tar -xzf /tmp/shoutcast.tar.gz -C /tmp/shoutcast && \
    find /tmp/shoutcast -type f -name sc_serv -exec cp {} /usr/local/bin/sc_serv \; && \
    chmod 755 /usr/local/bin/sc_serv && \
    rm -rf /tmp/shoutcast /tmp/shoutcast.tar.gz

# =====================================================================
# Create radio user
# =====================================================================

RUN groupadd -r radio && \
    useradd -r -g radio -d /home/radio -m radio

# =====================================================================
# Directory structure
# =====================================================================

RUN mkdir -p \
    /config \
    /music \
    /logs \
    /etc/shoutcast \
    /etc/liquidsoap \
    /var/log/icecast2 \
    /var/log/shoutcast \
    /var/log/liquidsoap

# =====================================================================
# Environment defaults
# =====================================================================

ENV HOSTNAME="ice.pucknell.co.uk" \
    SOURCE_PW="changeme123456" \
    RELAY_PW="changeme123456" \
    ADMIN_USER="admin" \
    ADMIN_PW="dLof1kXYWaN6FDA" \
    SHOUTCAST_AUTH_HASH="884800d8-e963-4d33-9e2b-78e7d638db55" \
    ICECAST_LOCATION="UK" \
    ICECAST_ADMIN_EMAIL="icemaster@localhost" \
    STATION_NAME="Fungus Radio" \
    STATION_DESCRIPTION="No Chat, Just Good Music." \
    STATION_GENRE="House, Dance, Eclectic" \
    STATION_URL="http://shout.pucknell.co.uk/" \
    ICECAST_PORT="8000" \
    SHOUTCAST_PORT="8001" \
    LIVE_PORT="8003" \
    TEST_PORT="8004" \
    BITRATE="320" \
    MUSIC_DIR="/music"

# =====================================================================
# Config files
# =====================================================================

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY logrotate-radio /etc/logrotate.d/radio

RUN chmod 755 /entrypoint.sh

# =====================================================================
# Ownership
# =====================================================================

RUN chown -R radio:radio \
    /config \
    /music \
    /logs \
    /etc/shoutcast \
    /etc/liquidsoap \
    /var/log/icecast2 \
    /var/log/shoutcast \
    /var/log/liquidsoap

# =====================================================================
# Ports
# =====================================================================

EXPOSE 8000
EXPOSE 8001
EXPOSE 8003
EXPOSE 8004

# =====================================================================
# Healthcheck
# =====================================================================

HEALTHCHECK \
  --interval=30s \
  --timeout=10s \
  --start-period=60s \
  --retries=3 \
  CMD curl -fs http://localhost:${ICECAST_PORT}/status-json.xsl || exit 1

# =====================================================================
# Run as non-root
# =====================================================================

USER radio

ENTRYPOINT ["/entrypoint.sh"]
