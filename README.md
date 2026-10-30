Internet Radio Server
A Docker-based Internet radio platform including:
Icecast 2
Liquidsoap
SHOUTcast DNAS
Supervisor
Log rotation
Health checks
Features
Automated playlist playback
Live DJ takeover via Liquidsoap Harbor
Icecast and SHOUTcast outputs
Environment-driven configuration
Multiple DJ accounts via users.txt
Docker health monitoring
Auto-reloading playlists
Directory Structure
```text
radio/
├── Dockerfile
├── docker-compose.yml
├── config/
│   ├── icecast.xml.template
│   ├── sc_serv.conf.template
│   ├── radio.liq.template
│   └── users.txt
├── music/
└── logs/
```
Build
```bash
docker build -t radio-server .
```
Quick Start
```bash
mkdir -p config music logs
```
Create `config/users.txt`:
```text
dj1:StrongPassword123
dj2:AnotherStrongPassword456
```
Copy music files into:
```text
music/
```
Docker Run Example
```bash
docker run -d \
  --name radio \
  --restart unless-stopped \
  -p 8000:8000 \
  -p 8001:8001 \
  -p 8003:8003 \
  -p 8004:8004 \
  -v $(pwd)/config:/config \
  -v $(pwd)/music:/music \
  -v $(pwd)/logs:/logs \
  -e HOSTNAME=radio.example.com \
  -e ADMIN_USER=admin \
  -e ADMIN_PW='ReplaceMe' \
  -e SOURCE_PW='ReplaceMe' \
  -e RELAY_PW='ReplaceMe' \
  -e STATION_NAME='My Radio Station' \
  -e STATION_DESCRIPTION='24/7 Music' \
  -e STATION_GENRE='Rock' \
  -e STATION_URL='https://radio.example.com' \
  radio-server
```
Docker Compose
```bash
docker compose up -d
```
Default Ports
Service	Port
Icecast	8000
SHOUTcast	8001
Live DJ Input	8003
Test DJ Input	8004
Listener URLs
```text
http://server:8000/radio-128.mp3
http://server:8000/radio-320.mp3
http://server:8000/radio.opus
```
Health Check
```bash
docker inspect radio --format='{{json .State.Health}}'
```
Logs
```bash
docker logs -f radio
```
Security
Change the default values for:
ADMIN_PW
SOURCE_PW
RELAY_PW
Restrict DJ ports (8003 and 8004) with a firewall where possible.
