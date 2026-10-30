FROM ubuntu:24.04
LABEL description="Icecast + Liquidsoap + SHOUTcast Radio Server"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y icecast2 liquidsoap ffmpeg supervisor gettext-base curl wget tar logrotate ca-certificates && apt-get clean && rm -rf /var/lib/apt/lists/*
ARG SHOUTCAST_URL=https://download.nullsoft.com/shoutcast/tools/sc_serv2_linux_x64-latest.tar.gz
RUN mkdir -p /tmp/shoutcast && wget -O /tmp/shoutcast.tar.gz "${SHOUTCAST_URL}" || true
RUN groupadd -r radio && useradd -r -g radio -d /home/radio -m radio
RUN mkdir -p /config /music /logs /etc/shoutcast /etc/liquidsoap /var/log/icecast2 /var/log/shoutcast /var/log/liquidsoap
ENV HOSTNAME=localhost SOURCE_PW=ChangeMe123456! RELAY_PW=ChangeMe123456! ADMIN_USER=admin ADMIN_PW=ChangeThisAdminPassword123! SHOUTCAST_AUTH_HASH='' ICECAST_LOCATION=Unknown ICECAST_ADMIN_EMAIL=admin@example.com STATION_NAME='Internet Radio' STATION_DESCRIPTION='24/7 Internet Radio Station' STATION_GENRE=Various STATION_URL=https://example.com ICECAST_PORT=8000 SHOUTCAST_PORT=8001 LIVE_PORT=8003 TEST_PORT=8004 BITRATE=320 MAX_CLIENTS=1000 MAX_SOURCES=10 LOG_LEVEL=3 MUSIC_DIR=/music
COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY logrotate-radio /etc/logrotate.d/radio
RUN chmod 755 /entrypoint.sh
EXPOSE 8000 8001 8003 8004
ENTRYPOINT ["/entrypoint.sh"]
