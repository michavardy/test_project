## wireguard

```bash
cd /opt
sudo mkdir wireguard
cd /wireguard
# copy docker compose into this directory
```

### references
#### Dockerhub: https://hub.docker.com/r/linuxserver/wireguard
#### Documentation: https://github.com/linuxserver/docker-wireguard
#### Youtube example: https://www.youtube.com/watch?v=AkKz7Vza1rw

### Required Changes
- time-zone: jerusalem
- server url: static IP
- peers: number of connections to it
- peerdns: ?
- internal subnets: ?
- allowedIPs: ?
- 

### Docker-compose
```yaml
---
version: "2.1"
services:
  wireguard:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Jerusalem
      - SERVERURL=82.166.86.139 #optional
      - SERVERPORT=51820 #optional
      - PEERS=3 #optional
      - PEERDNS=auto #optional
      - INTERNAL_SUBNET=10.13.13.0 #optional
      - ALLOWEDIPS=0.0.0.0/0 #optional
      - PERSISTENTKEEPALIVE_PEERS= #optional
      - LOG_CONFS=true #optional
    volumes:
      - /opt/wireguard/config:/config
      - /lib/modules:/lib/modules #optional
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```