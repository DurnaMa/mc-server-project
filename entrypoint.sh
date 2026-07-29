#!/bin/bash

# 1.Defaults setzen
: "${MINECRAFT_PORT:=25565}"
: "${MAX_PLAYERS:=20}"
: "${MOTD:=A Minecraft Server}"
: "${DIFFICULTY_LEVEL:=easy}"
: "${MAX_MEMORY:=2048M}"
: "${EULA:=true}"

echo "eula=${EULA}" > eula.txt

export MINECRAFT_PORT MAX_PLAYERS MOTD DIFFICULTY_LEVEL

envsubst < server.properties.template > server.properties

exec java -Xmx${MAX_MEMORY} -Xms${MAX_MEMORY} -jar server.jar nogui
