#------------------------------------------------------------------------------
# All the tools required to build mysql-migrator, including execution
# of integration tests.
#
# Build from the basedir:
#   docker build -f docker/Dockerfile-build -t mysql-migrator-build docker
#
# Verify the content of the image by running a shell session in it:
#   docker run -it mysql-migrator-build bash
#
# CirrusCI builds the image when needed. No need to manually upload it
# to Google Cloud Container Registry. See section "gke_container" of .cirrus.yml
#------------------------------------------------------------------------------

FROM maven:3.6-jdk-11

USER root

# Avoiding JVM Delays Caused by Random Number Generation (https://docs.oracle.com/cd/E13209_01/wlcp/wlss30/configwlss/jvmrand.html)
RUN sed -i 's|securerandom.source=file:/dev/random|securerandom.source=file:/dev/urandom|g' $JAVA_HOME/jre/lib/security/java.security
RUN apt-get update && apt-get -y install xvfb
RUN groupadd -r sonarsource && useradd -r -g sonarsource sonarsource

COPY settings.xml /etc/maven/settings.xml

USER sonarsource