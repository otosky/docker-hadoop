ARG HIVE_VERSION=2.3.7
FROM otosky/apache_downloader:v1.0 as dl
ARG HIVE_VERSION

ENV HIVE_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ENV HIVE_ASC https://downloads.apache.org/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz.asc

RUN curl -O https://downloads.apache.org/hive/KEYS \
    && gpg --import KEYS \
    && wget $HIVE_URL -O apache-hive-$HIVE_VERSION-bin.tar.gz \
    && wget $HIVE_ASC \
    && gpg --verify apache-hive-$HIVE_VERSION-bin.tar.gz.asc

RUN tar -xvzf apache-hive-$HIVE_VERSION-bin.tar.gz -C / \
	&& mv apache-hive-$HIVE_VERSION-bin /hive \
	&& wget https://jdbc.postgresql.org/download/postgresql-42.2.12.jar

## MAIN
FROM otosky/hadoop-tez:2.10.0

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CLASSPATH $HADOOP_CLASSPATH:$HIVE_HOME/lib/*
ENV HIVE_CONF_DIR $HIVE_HOME/conf

WORKDIR /opt

RUN apt-get update && apt-get install -y --no-install-recommends \
	procps \
	&& rm -rf /var/lib/apt/lists/*
COPY --from=dl /hive $HIVE_HOME
COPY --from=dl /postgresql-42.2.12.jar $HIVE_HOME/lib/postgresql-jdbc.jar

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10000 10002

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh