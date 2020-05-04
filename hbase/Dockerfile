ARG HBASE_VERSION=1.5.0
ARG HADOOP_VERSION=2.10.0
# Download & Verify Source Code
FROM otosky/apache_downloader:v1.0 AS dl

ARG HBASE_VERSION
ARG HADOOP_VERSION

ENV HBASE_ASC https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-src.tar.gz.asc
ENV HBASE_URL https://archive.apache.org/dist/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-src.tar.gz
RUN curl -O https://archive.apache.org/dist/hbase/KEYS \
    && gpg --import KEYS \
    && wget "$HBASE_URL" \
    && wget "$HBASE_ASC" \
    && gpg --verify hbase-${HBASE_VERSION}-src.tar.gz.asc \
    && tar -xvf hbase-${HBASE_VERSION}-src.tar.gz \
    && rm hbase-${HBASE_VERSION}-src.tar.gz* \
    && ls -l

FROM maven:3.6-jdk-8-slim as build
ARG HBASE_VERSION
ARG HADOOP_VERSION
RUN mkdir /hbase
COPY --from=dl hbase-${HBASE_VERSION} /hbase
WORKDIR /hbase
RUN sed -i "s|<hadoop-two.version>2.8.5|<hadoop-two.version>${HADOOP_VERSION}|" pom.xml \
    && mvn -DskipTests=true package assembly:single
RUN tar -xvzf hbase-assembly/target/hbase-${HBASE_VERSION}-bin.tar.gz -C /

## MAIN
FROM openjdk:8-slim-buster
LABEL maintainer="Oliver Tosky" \
      maintainer-email="olivertosky@gmail.com"
ARG HBASE_VERSION
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    net-tools \
    curl \
    netcat \
    && mkdir -p /opt/hbase

COPY --from=build /hbase-${HBASE_VERSION} /opt/hbase-${HBASE_VERSION}


RUN ln -s /opt/hbase-$HBASE_VERSION/conf /etc/hbase
RUN mkdir /opt/hbase-$HBASE_VERSION/logs

RUN mkdir /hadoop-data

ENV HBASE_PREFIX=/opt/hbase-$HBASE_VERSION
ENV HBASE_CONF_DIR=/etc/hbase

ENV USER=root
ENV PATH $HBASE_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]