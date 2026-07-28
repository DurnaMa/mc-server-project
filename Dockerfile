FROM eclipse-temurin:25-jre

WORKDIR /minecraft

RUN apt-get update && apt-get install -y wget gettext-base && wget https://piston-data.mojang.com/v1/objects/823e2250d24b3ddac457a60c92a6a941943fcd6a/server.jar -O server.jar && rm -rf /var/lib/apt/lists/*

COPY . .

RUN chmod +x entrypoint.sh

EXPOSE ${MINECRAFT_PORT}

ENTRYPOINT [ "./entrypoint.sh" ]