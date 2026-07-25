FROM eclipse-temurin:25-jre

WORKDIR /minecraft

COPY . .

ENV MINECRAFT_PORT=25565

RUN apt-get update && apt-get install -y wget && wget https://piston-data.mojang.com/v1/objects/823e2250d24b3ddac457a60c92a6a941943fcd6a/server.jar -O server.jar

EXPOSE ${MINECRAFT_PORT}

ENTRYPOINT [ "java", "-Xmx4G", "-Xms4G", "-jar", "server.jar", "nogui" ]