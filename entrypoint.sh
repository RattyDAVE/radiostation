#!/bin/bash
set -euo pipefail
required_vars=(SOURCE_PW ADMIN_USER ADMIN_PW HOSTNAME)
for v in "${required_vars[@]}"; do [ -n "${!v:-}" ] || exit 1; done
mkdir -p /etc/icecast2 /etc/shoutcast /etc/liquidsoap
envsubst < /config/icecast.xml.template > /etc/icecast2/icecast.xml
envsubst < /config/sc_serv.conf.template > /etc/shoutcast/sc_serv.conf
envsubst < /config/radio.liq.template > /etc/liquidsoap/radio.liq
{
 echo 'users = ['
 first=1
 while IFS= read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  user="${line%%:*}"; pass="${line#*:}"
  [ ${#pass} -lt 8 ] && exit 1
  if [ $first -eq 0 ]; then echo ','; fi
  first=0
  printf '    ("%s","%s")' "$user" "$pass"
 done < /config/users.txt
 echo
 echo ']'
} > /etc/liquidsoap/users.liq
liquidsoap --check /etc/liquidsoap/radio.liq || true
exec /usr/bin/supervisord -n
