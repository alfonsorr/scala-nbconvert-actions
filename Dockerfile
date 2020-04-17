FROM jupyter/base-notebook

RUN curl -L -o coursier https://git.io/coursier-cli && \
chmod +x coursier\
SCALA_VERSION=2.12.10 ALMOND_VERSION=0.9.1 \
./coursier bootstrap \
  -r jitpack \
  -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
  sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
  --sources --default=true \
  -o ./almond-scala-2.12 && \
./almond-scala-2.12 --install --id scala212 --display-name "Scala (2.12)" \
  --command "java -XX:MaxRAMPercentage=80.0 -jar almond-scala-2.12 --id scala212 --display-name 'Scala (2.12)'" \
  --copy-launcher \
  --metabrowse && \
rm -f almond-scala-2.12

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
