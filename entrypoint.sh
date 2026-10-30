#!/bin/bash

set -euo pipefail

# ============================================================
# Utility Functions
# ============================================================

log() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

# ============================================================
# Copy Default Files
# ============================================================

copy_if_missing() {

    local source="$1"
    local destination="$2"

    if [ ! -f "$destination" ]; then
        log "Creating $(basename "$destination") from defaults"
        cp "$source" "$destination"
    fi
}

# ============================================================
# Validation
# ============================================================

validate_required_vars() {

    local vars=(
        HOSTNAME
        SOURCE_PW
        ADMIN_USER
        ADMIN_PW
    )

    for var in "${vars[@]}"
    do
        if [ -z "${!var:-}" ]; then
            error "$var is not defined"
            exit 1
        fi
    done
}

validate_password() {

    local name="$1"
    local value="$2"

    if [ "${#value}" -lt 12 ]; then
        error "$name must be at least 12 characters"
        exit 1
    fi

    case "$value" in
        password|admin|changeme|secret|ChangeMe123456!)
            error "$name uses an insecure value"
            exit 1
            ;;
    esac
}

validate_music_directory() {

    if [ ! -d "$MUSIC_DIR" ]; then
        error "Music directory does not exist"

        exit 1
    fi

    MUSIC_COUNT=$(find "$MUSIC_DIR" \
        -type f \
        \( \
            -iname "*.mp3" \
            -o -iname "*.ogg" \
            -o -iname "*.opus" \
            -o -iname "*.flac" \
            -o -iname "*.aac" \
            -o -iname "*.m4a" \
        \) | wc -l)

    if [ "$MUSIC_COUNT" -eq 0 ]; then
        warn "No audio files found in $MUSIC_DIR"
    fi
}

validate_users_file() {

    USER_FILE="/config/users.txt"

    if [ ! -f "$USER_FILE" ]; then
        error "/config/users.txt not found"

        exit 1
    fi

    PERMISSIONS=$(stat -c "%a" "$USER_FILE")

    case "$PERMISSIONS" in
        600|640|644)
            ;;
        *)
            warn "users.txt permissions are $PERMISSIONS"
            warn "Recommended permissions: 600"
            ;;
    esac
}

# ============================================================
# Template Processing
# ============================================================

generate_users_file() {

    local count=0
    local first=true

    echo "users = ["

    while IFS= read -r line || [ -n "$line" ]
    do

        [ -z "$line" ] && continue

        if [[ "$line" != *:* ]]; then
            error "Invalid user entry: $line"

            exit 1
        fi

        user="${line%%:*}"
        pass="${line#*:}"

        if ! [[ "$user" =~ ^[a-zA-Z0-9._-]{1,64}$ ]]; then
            error "Invalid username: $user"

            exit 1
        fi

        if [ "${#pass}" -lt 8 ]; then
            error "Password too short for user: $user"

            exit 1
        fi

        user=$(printf '%s' "$user" \
            | sed 's/\\/\\\\/g;s/"/\\"/g')

        pass=$(printf '%s' "$pass" \
            | sed 's/\\/\\\\/g;s/"/\\"/g')

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        printf '    ("%s","%s")' \
            "$user" \
            "$pass"

        count=$((count + 1))

    done < /config/users.txt

    echo
    echo "]"

    DJ_COUNT="$count"
}

generate_configs() {

    envsubst \
        < /config/icecast.xml.template \
        > /etc/icecast2/icecast.xml

    envsubst \
        < /config/sc_serv.conf.template \
        > /etc/shoutcast/sc_serv.conf

    envsubst \
        < /config/radio.liq.template \
        > /etc/liquidsoap/radio.liq

    generate_users_file \
        > /etc/liquidsoap/users.liq
}

# ============================================================
# Liquidsoap Validation
# ============================================================

validate_liquidsoap_config() {

    log "Validating Liquidsoap configuration"

    liquidsoap --check \
        /etc/liquidsoap/radio.liq
}

# ============================================================
# Startup Summary
# ============================================================

show_summary() {

cat <<EOF

====================================================
Internet Radio Server
====================================================

Hostname           : ${HOSTNAME}

Icecast Port       : ${ICECAST_PORT}
SHOUTcast Port     : ${SHOUTCAST_PORT}

Live Input Port    : ${LIVE_PORT}
Test Input Port    : ${TEST_PORT}

Station Name       : ${STATION_NAME}

DJ Accounts        : ${DJ_COUNT}
Music Files        : ${MUSIC_COUNT}

Music Directory    : ${MUSIC_DIR}

====================================================

EOF

}

# ============================================================
# Main
# ============================================================

copy_if_missing \
    /defaults/icecast.xml.template \
    /config/icecast.xml.template

copy_if_missing \
    /defaults/sc_serv.conf.template \
    /config/sc_serv.conf.template

copy_if_missing \
    /defaults/radio.liq.template \
    /config/radio.liq.template

copy_if_missing \
    /defaults/users.txt \
    /config/users.txt

validate_required_vars

validate_password \
    "SOURCE_PW" \
    "$SOURCE_PW"

validate_password \
    "ADMIN_PW" \
    "$ADMIN_PW"

validate_users_file

validate_music_directory

generate_configs

validate_liquidsoap_config

show_summary

log "Starting Supervisor"

exec /usr/bin/supervisord -n
