#!/bin/bash
# Port aus ENV in die properties schreiben:
sed -i "s/^server-port=.*/server-port=${MINECRAFT_PORT}/" server.properties
# dann erst den Server starten:
exec java -Xmx4G -Xms4G -jar server.jar nogui