ARG TEZ_VERSION=0.9.2
FROM otosky/apache_downloader:v1.0 AS dl 
ARG TEZ_VERSION

ENV TEZ_URL ${APACHE_URL_PREFIX}tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-src.tar.gz
ENV TEZ_ASC https://downloads.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-src.tar.gz.asc

RUN curl -O https://downloads.apache.org/tez/KEYS \
    && gpg --import KEYS \
    && wget $TEZ_URL -O apache-tez-$TEZ_VERSION-src.tar.gz\
    && wget $TEZ_ASC \
    && gpg --verify apache-tez-${TEZ_VERSION}-src.tar.gz.asc

FROM otosky/hadoop-base:2.10.0 AS builder
ARG TEZ_VERSION
RUN mkdir -p /usr/share/man/man1
ENV JAVA_HOME=/usr/local/openjdk-8/

RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    wget \
    bzip2 \
    git \
    automake \
    autoconf \
    make \
    libtool \
    gcc \
    g++

ENV LD_LIBRARY_PATH=/usr/local/lib

# COMPILE PROTOBUF
RUN wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz && tar zvxf protobuf-2.5.0.tar.gz && rm protobuf-2.5.0.tar.gz
WORKDIR /protobuf-2.5.0
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make
RUN make install
WORKDIR /

# COMPILE TEZ
ENV SRC_TAR /apache-tez-${TEZ_VERSION}-src.tar.gz
COPY --from=dl $SRC_TAR /
RUN tar xvzf $SRC_TAR -C /opt \
    && rm $SRC_TAR

RUN sed -i "s|<hadoop.version>2.7.2</hadoop.version>|<hadoop.version>$HADOOP_VERSION</hadoop.version>|" /opt/apache-tez-$TEZ_VERSION-src/pom.xml
COPY tez-ui-pom.xml /opt/apache-tez-0.9.2-src/tez-ui/

RUN cd /opt/apache-tez-0.9.2-src \
    && mv -f tez-ui/tez-ui-pom.xml tez-ui/pom.xml \
    && mvn clean package -DskipTests=true -Dmaven.javadoc.skip=true

RUN mkdir -p /tmp/tez \
    && mkdir -p /opt/tez \
    && cd /opt/apache-tez-0.9.2-src/tez-dist/target \
    && tar -xvzf tez-$TEZ_VERSION-minimal.tar.gz -C /opt/tez

# MAIN
FROM otosky/hadoop-base:2.10.0

# TEZ 
ARG TEZ_VERSION
ENV TEZ_HOME=/opt/tez
ENV TEZ_CONF_DIR=$TEZ_HOME/conf

COPY --from=builder /opt/tez $TEZ_HOME
COPY --from=builder /opt/apache-tez-$TEZ_VERSION-src/tez-dist/target/tez-$TEZ_VERSION.tar.gz /tmp/tez/
ADD tez-site.xml $TEZ_CONF_DIR/ 

ENV TEZ_JARS=$TEZ_HOME
ENV HADOOP_CLASSPATH=${TEZ_CONF_DIR}:${TEZ_JARS}/*:${TEZ_JARS}/lib/*