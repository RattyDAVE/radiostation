FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    icecast2 \
    liquidsoap \
    ffmpeg \
    supervisor \
    gettext-base \
    curl \
    logrotate \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Non-root user
RUN groupadd -r radio && \
    useradd -r -g radio -d /home/radio -m radio

# Directories
RUN mkdir -p \
    /config \
    /music \
    /logs \
    /var/log/icecast2 \
    /var/log/shoutcast \
    /var/log/liquidsoap \
    /etc/shoutcast \
    /etc/liquidsoap

COPY icecast.xml.template /config/
COPY sc_serv.conf.template /config/
COPY radio.liq.template /config/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY logrotate-radio /etc/logrotate.d/radio

RUN chmod +x /entrypoint.sh && \
    chown -R radio:radio \
        /config \
        /music \
        /logs \
        /var/log/icecast2 \
        /var/log/shoutcast \
        /var/log/liquidsoap

EXPOSE 8000 8001 8003 8004

HEALTHCHECK \
    --interval=30s \
    --timeout=10s \
    --start-period=60s \
    --retries=3 \
    CMD curl -fs http://localhost:${ICECAST_PORT}/status-json.xsl || exit 1

USER radio

ENTRYPOINT ["/entrypoint.sh"]
