# home-studio

Self-hosted home media server stack. Torrents are routed through a Mullvad WireGuard VPN (kill switch enforced). Media is served via Jellyfin, with Sonarr/Radarr handling automated acquisition and Jellyseerr as the request UI.

## Stack

| Service | Purpose | Port |
|---|---|---|
| [Gluetun](https://github.com/qdm12/gluetun) | Mullvad WireGuard VPN + kill switch | — |
| [qBittorrent](https://github.com/linuxserver/docker-qbittorrent) | Torrent client (routed through VPN) | 8080 |
| [Prowlarr](https://github.com/Prowlarr/Prowlarr) | Indexer manager | 9696 |
| [Sonarr](https://sonarr.tv) | TV show automation | 8989 |
| [Radarr](https://radarr.video) | Movie automation | 7878 |
| [Bazarr](https://www.bazarr.media) | Subtitle automation | 6767 |
| [Jellyfin](https://jellyfin.org) | Media server | 8096 |
| [Jellyseerr](https://github.com/Fallenbagel/jellyseerr) | Media request UI | 5055 |
| [Homepage](https://gethomepage.dev) | Dashboard | 3000 |

qBittorrent runs with `network_mode: service:gluetun` — if the VPN drops, all torrent traffic stops.

## Prerequisites

- Linux server (tested on Ubuntu)
- Docker + Docker Compose
- Mullvad account with a WireGuard key pair generated ([Mullvad WireGuard config](https://mullvad.net/en/account/#/wireguard-config) — select Linux / WireGuard / Canada)
- Tailscale (for remote access)

## Setup

**1. Bootstrap the server**

```bash
bash scripts/setup.sh
```

This installs Docker, Tailscale, configures UFW (allows LAN `192.168.0.0/16` and Tailscale `100.64.0.0/10`), disables lid-close suspend, and creates the media directory structure.

Log out and back in after running so the Docker group takes effect.

**2. Configure environment**

```bash
cp env.example .env
nano .env
```

Fill in your Mullvad WireGuard private key and assigned address. Adjust `MEDIA_DIR`, `CONFIG_DIR`, `PUID`/`PGID` (run `id` to get your user/group IDs), and `TZ` as needed.

**3. Start the stack**

```bash
docker compose up -d
```

## Directory structure

```
MEDIA_DIR/
  movies/
  tv/
  downloads/

CONFIG_DIR/
  qbittorrent/
  prowlarr/
  sonarr/
  radarr/
  bazarr/
  jellyfin/
  jellyseerr/
  homepage/
```

## Post-setup configuration

1. **Prowlarr** (`http://server:9696`) — add indexers
2. **Sonarr / Radarr** — connect to Prowlarr and set qBittorrent as the download client (host: `gluetun`, port: `8080`)
3. **Bazarr** — connect to Sonarr and Radarr
4. **Jellyseerr** — connect to Jellyfin, Sonarr, and Radarr
5. **Homepage** — configure `CONFIG_DIR/homepage/` for your dashboard widgets
