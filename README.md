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
- [Files](#files)
- [Quickstart](#quickstart)
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
- [Usage](#usage)
  - [Change the server port](#change-the-server-port)
  - [Persisted world data](#persisted-world-data)
  - [How the entrypoint script works](#how-the-entrypoint-script-works)
  - [Adjust server memory (RAM)](#adjust-server-memory-ram)
  - [Test the server](#test-the-server)
  - [Accept the EULA](#accept-the-eula)

## Files

| File | Purpose |
|---|---|
| `README.md` | This documentation |
| `Dockerfile` | Builds the server image and downloads `server.jar` |
| `docker-compose.yaml` | Defines the `mc-server` service, ports, volume and variables |
| `entrypoint.sh` | Sets defaults, renders the config, starts the server |
| `server.properties.template` | Template with `${...}` placeholders |
| `.gitignore` | Excludes generated files from Git |
| `.dockerignore` | Excludes files from the build context |
| `.gitattributes` | Enforces LF line endings for shell scripts |

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

3. Create a `.env` file and accept the Minecraft EULA:
```bash
echo "EULA=true" > .env
```

By setting this value you agree to the [Minecraft EULA](https://aka.ms/MinecraftEULA).
The server will not start without it.

4. Build and start the server:
```bash
sudo docker compose up --build
```

The server is now running and reachable on port `8888`.

## Usage

This section explains how to configure the server.

### Accept the EULA

Mojang requires every server operator to accept the EULA. The default is `false`,
so the repository does not accept it on your behalf. The value is passed in
through a `.env` file, which is excluded from Git by `.gitignore`.

Without `EULA=true`, the container starts, writes `eula=false` and exits.

### Change the server port
The port is defined in two places in [`docker-compose.yaml`](docker-compose.yaml):
under `ports:` (the right value is the container port) and in the `environment:`
block under `MINECRAFT_PORT`. Both values must match exactly.

After changing both values, recreate the container. No rebuild is needed:

```bash
sudo docker compose up -d --force-recreate
```

### Persisted world data

The world data is stored in a named volume managed by Docker. It survives
`docker compose down` and container restarts.

The volume is declared in two places in [`docker-compose.yaml`](docker-compose.yaml):
once in the service under `volumes`, and once in the top-level `volumes` block.
Without the second one, Compose refuses to start.

> [!WARNING]
> Do not change the right side (`/minecraft/world`). It is the path inside the 
> container, defined by `WORKDIR` in the Dockerfile.
> 
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
| `EULA` | `false` | Must be set to `true` to start the server |

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