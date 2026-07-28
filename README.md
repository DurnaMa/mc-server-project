## Table of Contents
- [Description](#description)
- [Quickstart](#quickstart)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
- [Usage](#usage)
  - [Change the server port](#change-the-server-port)
  - [Persisted world data](#persisted-world-data)
  - [How the entrypoint script works](#how-the-entrypoint-script-works)
  - [Adjust server memory (RAM)](#adjust-server-memory-ram)
  - [Test the server](#test-the-server)

## Description

This repository provides a self-hosted Minecraft Java server running in Docker.
It does not use a pre-built Minecraft image. Instead, the server image is built
from a custom Dockerfile.

Key features:
- The server port can be configured flexibly through an environment variable.
- The world data is persisted through a Docker volume, so the game progress is
  kept even after the container is stopped or crashes.

## Quickstart

### Prerequisites
- Docker installed — check with: `docker -v`
- Docker Compose installed — check with: `docker compose version`

> [!NOTE] The commands below use `sudo`. If you run Docker as root or your user
> is in the `docker` group, you can omit `sudo`.

### Steps
1. Clone the repository: 
```bash
git clone https://github.com/DurnaMa/mc-server-project
```

2. Change into the project directory: 
```bash
cd mc-server-project
```

3. Build and start the server:
```bash
sudo docker compose up --build
```

The server is now running and reachable on port `8888`.

## Usage

This section explains how to configure the server.

### Change the server port
The internal port is controlled by the `MINECRAFT_PORT` variable. To change it,
edit **two matching values** in `docker-compose.yaml`:

```yaml
ports:
  - "8888:25565"        # change the right value (container port)
environment:
  MINECRAFT_PORT: 25565 # must match the right value above
```

The left value of `ports` (`8888`) is the external port and can stay as it is.
After changing it, rebuild and restart:

```bash
sudo docker compose up --build
```

### Persisted world data
Only the `world/` folder is persisted through a volume. The storage location on
the host (left side) can be chosen freely:

```yaml
volumes:
  - ./world:/minecraft/world   # left = host (free), right = container (fixed)
```

Do not change the right side (`/minecraft/world`) — it must match the server's
working directory.

### How the entrypoint script works
When the container starts, it runs `entrypoint.sh`. This script writes the value
of the `MINECRAFT_PORT` variable into `server.properties` and then starts the
Minecraft server:

```sh
#!/bin/sh
sed -i "s/^server-port=.*/server-port=${MINECRAFT_PORT}/" server.properties
exec java -Xmx4G -Xms4G -jar server.jar nogui
```

- `sed` replaces the `server-port` line in `server.properties` with the value
  from `MINECRAFT_PORT`.
- `exec` starts Java so the server reacts correctly to stop signals.

### Adjust server memory (RAM)
The memory limits are set in `entrypoint.sh`:

```bash
exec java -Xmx4G -Xms4G -jar server.jar nogui
```

- `-Xmx4G` = maximum RAM
- `-Xms4G` = initial RAM

Change these values and rebuild the image.

### Test the server
You can test the server with the Python tool `mcstatus`:

```bash
python3 -m venv venv
source venv/bin/activate
pip install mcstatus
mcstatus localhost:8888 status
```

A successful response shows the version, player count and ping.