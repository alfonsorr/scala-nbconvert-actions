FROM openjdk:8-alpine as download

WORKDIR /path

RUN apk --no-cache add curl && \
curl -L -o coursier https://git.io/coursier-cli && \
chmod +x coursier && \
SCALA_VERSION=2.12.10 && ALMOND_VERSION=0.9.1 && \
./coursier bootstrap \
  -r jitpack \
  -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
  sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
  --sources --default=true \
  -o /path/almond-scala-2.12

FROM jupyter/minimal-notebook

USER root
RUN apt-get update && apt-get install -y \
openjfx=8u161-b12-1ubuntu2 \
libopenjfx-jni=8u161-b12-1ubuntu2 \
libopenjfx-java=8u161-b12-1ubuntu2
USER $NB_USER

COPY --from=download /path/almond-scala-2.12 /path/almond-scala-2.12

RUN /path/almond-scala-2.12 --install --id scala212 --display-name "Scala (2.12)" \
  --command "java -XX:MaxRAMPercentage=80.0 -jar /path/almond-scala-2.12 --id scala212 --display-name 'Scala (2.12)'" \
  --copy-launcher \
  --metabrowse
USER root
RUN rm -f /path/almond-scala-2.12

COPY entrypoint.sh /home/jovyan/entrypoint.sh
RUN chmod +x /home/jovyan/entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/home/jovyan/entrypoint.sh"]
