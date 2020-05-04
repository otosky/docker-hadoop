ARG HADOOP_VERSION=2.10.0
FROM otosky/apache_downloader:v1.0 AS dl 

RUN mkdir pig spark
ENV PIG_URL ${APACHE_URL_PREFIX}pig/pig-0.17.0/pig-0.17.0.tar.gz
ENV PIG_ASC https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz.asc
RUN curl -O https://downloads.apache.org/pig/KEYS \
    && gpg --import KEYS \
    && wget $PIG_URL -O pig-0.17.0.tar.gz \
    && wget $PIG_ASC \
    && gpg --verify pig-0.17.0.tar.gz.asc

ENV PIG_HOME=/pig/pig-0.17.0
RUN tar xvzf pig-0.17.0.tar.gz --exclude=tutorial --exclude=test --exclude=src --exclude=docs -C /pig
RUN sed -i "s/tez.version=0.7.0/tez.version=$TEZ_VERSION/" $PIG_HOME/ivy/libraries.properties

ENV SPARK_URL ${APACHE_URL_PREFIX}spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop-scala-2.12.tgz
ENV SPARK_ASC https://downloads.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop-scala-2.12.tgz.asc
RUN curl -O https://downloads.apache.org/spark/KEYS \
    && gpg --import KEYS \
    && wget $SPARK_URL -O spark-2.4.5.tgz \
    && wget $SPARK_ASC -O spark-2.4.5.tgz.asc\
    && gpg --verify spark-2.4.5.tgz.asc
RUN tar xvzf spark-2.4.5.tgz \
    && mv spark-2.4.5-bin-without-hadoop-scala-2.12 spark-2.4.5

ENV SQOOP_URL ${APACHE_URL_PREFIX}sqoop/1.4.7/sqoop-1.4.7.tar.gz
ENV SQOOP_ASC https://downloads.apache.org/sqoop/1.4.7/sqoop-1.4.7.tar.gz.asc
RUN curl -O https://downloads.apache.org/sqoop/KEYS \
    && gpg --import KEYS \
    && wget $SQOOP_URL -O sqoop-1.4.7.tar.gz \
    && wget $SQOOP_ASC -O sqoop-1.4.7.tar.gz.asc\
    && gpg --verify sqoop-1.4.7.tar.gz.asc \
    && tar xvzf sqoop-1.4.7.tar.gz 

## SQOOP
FROM openjdk:8-slim-buster as sqoop

ARG HADOOP_VERSION
ENV JAVA_HOME=/usr/local/openjdk-8/
RUN mkdir -p /usr/share/man/man1 && mkdir sqoop-1.4.7
RUN apt-get update && apt-get install -y --no-install-recommends \
    ant \
    python-minimal \
    && rm -rf /var/lib/apt/lists/*

COPY --from=dl /sqoop-1.4.7 /sqoop-1.4.7

RUN cd sqoop-1.4.7 \
    && sed -i "s/hadoop.version=.*/hadoop.version=$HADOOP_VERSION/" ivy/libraries.properties \
    && sed -i "s|http:|https:|" build.xml \
    && sed -i "s|repo2.maven|repo1.maven|" build.xml \
    && sed -i "s|http://repo1|https://repo1|" ivy/ivysettings.xml \ 
    && sed -i "s|repo2.maven|repo1.maven|" ivy/ivysettings.xml \
    && ant package -Dskip-real-docs=true \
    && cd build/sqoop-1.4.7.bin__hadoop-$HADOOP_VERSION \
    && rm -r testdata src docs pom-old.xml

## MAIN
FROM otosky/hadoop-hive:2.10.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    vim \
    less \
    python-minimal \
    python3-minimal \
    && rm -rf /var/lib/apt/lists/*

# PIG
RUN mkdir -p /pig
COPY --from=dl /pig /opt/
ENV PIG_HOME=/opt/pig-0.17.0
ENV PATH=$PATH:$PIG_HOME/bin
ENV PIG_CLASSPATH=$HADOOP_CONF_DIR:$HADOOP_CLASSPATH
ENV PIG_OPTS=-Dpig.logfile=/tmp/pig_logs.log

# SQOOP
ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin
COPY --from=sqoop /sqoop-1.4.7/build/sqoop-1.4.7.bin__hadoop-$HADOOP_VERSION $SQOOP_HOME
COPY sqoop-env-template.sh $SQOOP_HOME/conf
RUN cp /opt/hive/jdbc/hive-jdbc-2.3.7-standalone.jar $SQOOP_HOME/lib/
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.12.jar -P /opt/sqoop/lib && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz \
    | tar -xvz -C / && \
    mv /mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar $SQOOP_HOME/lib/ && \
    rm -r /mysql-connector-java-8.0.19

# PRESTO
RUN wget https://repo1.maven.org/maven2/io/prestosql/presto-cli/332/presto-cli-332-executable.jar -O /bin/presto \
    && chmod +x /bin/presto
# ADD presto-server-332.tar.gz /opt/
# RUN mv /opt/presto-server-332 /opt/presto
# RUN mkdir /opt/presto/etc
# COPY presto-etc /opt/presto/etc

# ENV PRESTO_HOME=/opt/presto


# SPARK
RUN mkdir /opt/spark-2.4.5
ENV SPARK_HOME /opt/spark-2.4.5
COPY --from=dl /spark-2.4.5 $SPARK_HOME
COPY spark-env.sh $SPARK_HOME/conf/
COPY spark-defaults.conf $SPARK_HOME/conf/
ENV PATH $PATH:$SPARK_HOME/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$HADOOP_HOME/lib/native

COPY run.sh /
RUN chmod +x /run.sh

EXPOSE 8081 4040

CMD ["/run.sh"]