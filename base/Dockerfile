# Download & Verify Hadoop
FROM apache_downloader AS dl

ENV HADOOP_VERSION 2.10.0
ENV HADOOP_ASC https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz.asc
ENV HADOOP_URL ${APACHE_URL_PREFIX}hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_ASC" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz --exclude="share/doc" -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

# MAIN
FROM openjdk:8-slim-buster
LABEL maintainer="Oliver Tosky" \
      maintainer-email="olivertosky@gmail.com"

RUN mkdir -p /usr/share/man/man1
RUN apt-get update && apt-get install -y --no-install-recommends \
    netcat \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/local/openjdk-8/
ENV HADOOP_VERSION 2.10.0
RUN mkdir -p /opt/hadoop-$HADOOP_VERSION
COPY --from=dl /opt/hadoop-$HADOOP_VERSION /opt/hadoop-$HADOOP_VERSION

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs

RUN mkdir /hadoop-data

ENV HADOOP_PREFIX=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1

ENV USER=root
ENV PATH $HADOOP_PREFIX/bin/:$PATH

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
