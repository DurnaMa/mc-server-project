# MC-SERVER

This repository provides a self-hosted Minecraft Java server running in Docker.
It does not use a pre-built Minecraft image. Instead, the server image is built
from a custom Dockerfile.

Key features:
- Server port, player limit, MOTD, difficulty and RAM are configurable through
  environment variables.
- Configuration is applied at runtime, so no image rebuild is needed.
- The world data is persisted in a named Docker volume, so the game progress is
  kept even after the container is stopped or crashes.

## Table of Contents
- [Files](#Files)
- [Quickstart](#quickstart)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
- [Usage](#usage)
  - [Change the server port](#change-the-server-port)
  - [Persisted world data](#persisted-world-data)
  - [How the entrypoint script works](#how-the-entrypoint-script-works)
  - [Adjust server memory (RAM)](#adjust-server-memory-ram)
  - [Test the server](#test-the-server)

## Files

| File | Purpose |
|---|---|
| `README.md` | This documentation |
| `Dockerfile` | Builds the server image and downloads `server.jar` |
| `docker-compose.yaml` | Defines the `mc-server` service, ports, volume and variables |
| `entrypoint.sh` | Sets defaults, renders the config, starts the server |
| `server.properties.template` | Template with `${...}` placeholders |
| `eula.txt` | Accepts the Minecraft EULA |
| `.gitignore` | Excludes generated files from Git |
| `.dockerignore` | Excludes files from the build context |

## Quickstart

### Prerequisites
- Docker installed — check with: `docker -v`
- Docker Compose installed — check with: `docker compose version`

> [!NOTE] 
> The commands below use `sudo`. If you run Docker as root or your user is in the `docker` group, you can omit `sudo`.

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

After changing both values, recreate the container. No rebuild is needed:

```bash
sudo docker compose up -d --force-recreate
```

### Persisted world data

The world data is stored in a named volume managed by Docker. It survives
`docker compose down` and container restarts.

```yaml
services:
  mc-server:
    volumes:
      - world:/minecraft/world

volumes:
  world:
```

The volume must be declared in two places: once in the service, and once in the
top-level `volumes` block. Without the second one, Compose refuses to start.

Do not change the right side (`/minecraft/world`). It is the path inside the
container, defined by `WORKDIR` in the Dockerfile.

> [!WARNING]
> `docker compose down -v` deletes the volume and the world with it.

### How the entrypoint script works

On container start, `entrypoint.sh` sets a default for every variable,
renders `server.properties.template` with `envsubst`, and starts the server.

```bash
envsubst < server.properties.template > server.properties
```

| Variable | Default | Description |
|---|---|---|
| `MINECRAFT_PORT` | `25565` | Port inside the container |
| `MAX_PLAYERS`|`20`| Players inside the container |
| `MOTD` | `A Minecraft Server` | Message shown in the server list |
| `DIFFICULTY_LEVEL` | `easy` | Game difficulty: `peaceful`, `easy`, `normal`, `hard` |
| `MAX_MEMORY` | `2048M` | JVM heap size, not a server property |

To change a value, edit it in `docker-compose.yaml` and recreate the container.
No rebuild is needed:

```bash
sudo docker compose up -d --force-recreate
```

Verify the result:

```bash
sudo docker exec mc-server grep max-players server.properties
```

### Adjust server memory (RAM)

The default value is defined in `entrypoint.sh` and can be overridden in
`docker-compose.yaml`. It is passed to the JVM as `-Xmx` and `-Xms`, so it does
not appear in `server.properties`.

Keep the value well below the total RAM of your host. If the JVM requests more
memory than available, the container is killed on startup.

Valid formats: `2048M` or `2G`.

### Test the server
You can test the server with the Python tool `mcstatus`:

```bash
python3 -m venv venv
source venv/bin/activate
pip install mcstatus
mcstatus localhost:8888 status
```

A successful response shows the version, player count and ping.