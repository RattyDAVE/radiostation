# Internet Radio Server
 
A self-contained Internet radio server based on:
 
- Icecast 2
- Liquidsoap
- SHOUTcast DNAS
- Supervisor
- Docker
 
The container supports:
 
- Live DJ streams via Liquidsoap Harbor
- Automatic playlist playback
- Icecast streaming
- SHOUTcast streaming
- Multiple stream formats
- Automatic configuration using environment variables
- Docker health checks
- Log rotation
- Multiple DJ accounts
- Music library auto-reloading
 
---
 
# Features
 
## Supported Services
 
### Icecast
 
Provides:
 
- Listener connections
- Mount points
- Status pages
- Admin interface
 
Default Port:
 
```text
8000
SHOUTcast

Provides:

SHOUTcast listener support
SHOUTcast directory support
Legacy player compatibility

Default Port:

Plain Text
8001
Liquidsoap

Provides:

Playlist automation
DJ takeover
Live streams
Fallback streams

Default Harbor Ports:

Plain Text
Live DJ : 8003
Test DJ : 8004
 
Directory Structure

Create the following structure:

Plain Text
radio/
├── Dockerfile
├── docker-compose.yml
│
├── config/
│ ├── icecast.xml.template
│ ├── sc_serv.conf.template
│ ├── radio.liq.template
│ └── users.txt
│
├── music/
│ ├── Track1.mp3
│ ├── Track2.mp3
│ └── ...
│
└── logs/
Building

Build the container:

Shell
docker build -t radio-server .
Quick Start

Create:

Shell
mkdir -p config music logs

Add your music files:

Shell
cp *.mp3 music*

Create:

Plain Text
config/users.txt

Example:

Plain Text
dj1*VerySecure*assword123
dj2:AnotherSecure*assword456
Docker Run

Example:

Shell
docker run -* \
--name radio \
* --restart unless-stopped \
-p*8000:8000 \
-p*8001:8001 \
-p*8003:8003 \
-p*8004:8004 \
-v*$(pwd)/config:/config*\
-v $(pwd)/music:/music*\
-v $(pwd)/logs:/logs*\
-e HOSTNAME=radio*example.com \
-e ADMIN*USER=admin \
-e ADMIN_PW*'SuperSecure*dminPassword123' \
-e*SOURCE_PW='SuperSecureSourcePasswo*d123'*\
-e RELAY_PW='Super*ecureRelayPassword123' \
-e ST*TION_NAME='My Radio Station' \
*-e STATION_DESCRIPTION='Music*24 Hours A*Day' \
-e STATION_GENRE*'Rock' \
-e*STATION_URL='https://radio.example.com' \
radio-server
Docker Compose
YAML
services:
 
* radio:
build: .
 
containe*_name* radio
 
restart: unless-stoppe*
 
* ports:
- "8000:800*"
- "8001:8001*
- "8003:8003"
* - "8004:8004"
 
*volumes:
- ./config:/config
* *- ./music:/music
- ./logs*/logs
 
environment:
HOST*AME: radio.example.com
ADMIN*USER:*admin
ADMIN_PW: SuperSecureA*min*assword123
SOURCE_PW: SuperS*cureSourcePassword123
RELAY_*W:*SuperSecureRelayPassword123
 
* STATION_NAME: My Radio Statio*
*STATION_DESCRIPTION: Music 24 Hour* A Day* STATION_GENRE: Rock
ST*TION_URL: https://radio.example.co*
 
* healthcheck:
test:
* [
"CMD-SHELL",
"pgrep icecast2 >/dev/null && pgrep liquidsoap >/dev/null && curl --fail --silent http://127.0.0.1:8000/status-json.xsl >/dev/null"
]
interval: 30s
timeo*t: 10s
retries: 3
star*_period: 60s

Start:

Shell
*ocker compose up -d

View status:

Shell
docker compose ps
Environment Variables
Variable	DefaultHOSTNAME	localhost
ADMIN_USER	admin
ADMIN_PW	ChangeThisAdminPassword123!
SOURCE_PW	ChangeMe123456!
RELAY_PW	ChangeMe123456!
ICECAST_PORT	8000
SHOUTCAST_PORT	8001
LIVE_PORT	8003

| TEST_PORT | 8004 | | STATION_NAME | Internet Radio | | STATION_DESCRIPTION | 24/7 Internet Radio Station | | STATION_GENRE | Various | | STATION_URL | https://example.com | | BITRATE | 320 | | MAX_CLIENTS | 1000 | | MAX_SOURCES | 10 | | LOG_LEVEL | 3 | | MUSIC_DIR | /music |

Listener URLs

Icecast:

Plain Text
http://server:800*/radio-128.mp3
Plain Text
http://server:8000/r*dio-320.mp3
Plain Text
http://server:8000/radio.op*s

SHOUTcast:

Plain Text
http://server:8001
DJ Login

Default Live Input:

Plain Text
server: *your-server*port: 8003
format* Icecast/Sh*utcast Source

Test Input:

Plain Text
server: your*server
port: 8004
``*

Credentials:

Plain Text
config*users.txt

Example:

Plain Text
*j1:StrongPassword123*dj2:AnotherPassword*56
Admin Interface

Icecast Status:

Plain Text
http://server:8000
*

Admin:

Plain Text
http://server:8000/admin*

Login:

Plain Text
ADMIN_USER
*DMIN_PW
Useful Commands

Restart:

Shell
docker*restart radio*

View Logs:

Shell
docker*logs -f radio

Enter Container:

Shell
*ocker exec -it radio bash

Container Health:

Shell
docker inspect --*ormat='{{json .State.Health*}' radio
Security Recommendations

Always change:

Plain Text
ADMIN_PW
SOURCE_PW
*ELAY_PW

Use strong passwords.

Recommended:

Plain Text
16* characters
upper + lower case
num*ers*symbols

Restrict access to:

Plain Text
*003
8004
*

using a firewall if they are only used by DJs.

Updating

Rebuild:

Shell
docker build*-t radio-server .

Recreate:

Shell
docker compose down
docker *ompose up*-d --build
Troubleshooting

Check Icecast:

Shell
curl*http://localhost:8000/status-json*xsl

Check Container Health:

Shell
docker ps*

Check Liquidsoap Configuration:

Shell
liquidsoap --check /*tc/liquidsoap/radio.liq
``*

View Logs:

Shell
docker logs ** radio
Licence

Use at your own risk.

You are responsible for compliance with:

Icecast licensing
Liquidsoap licensing
SHOUTcast licensing
Music licensing in your jurisdiction
