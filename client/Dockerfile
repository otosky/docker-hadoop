ARG HADOOP_VERSION=2.10.0
FROM otosky/apache_downloader:v1.0 AS dl 

RUN mkdir pig spark
ENV PIG_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=pig/pig-0.17.0/pig-0.17.0.tar.gz
ENV PIG_ASC https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz.asc
RUN curl -O https://downloads.apache.org/pig/KEYS \
    && gpg --import KEYS \
    && wget $PIG_URL -O pig-0.17.0.tar.gz \
    && wget $PIG_ASC \
    && gpg --verify pig-0.17.0.tar.gz.asc

ENV PIG_HOME=/pig/pig-0.17.0
RUN tar xvzf pig-0.17.0.tar.gz --exclude=tutorial --exclude=test --exclude=src --exclude=docs -C /pig
RUN sed -i "s/tez.version=0.7.0/tez.version=$TEZ_VERSION/" $PIG_HOME/ivy/libraries.properties

ENV SPARK_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop-scala-2.12.tgz
ENV SPARK_ASC https://downloads.apache.org/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop-scala-2.12.tgz.asc
RUN curl -O https://downloads.apache.org/spark/KEYS \
    && gpg --import KEYS \
    && wget $SPARK_URL -O spark-2.4.5.tgz \
    && wget $SPARK_ASC -O spark-2.4.5.tgz.asc\
    && gpg --verify spark-2.4.5.tgz.asc
RUN tar xvzf spark-2.4.5.tgz \
    && mv spark-2.4.5-bin-without-hadoop-scala-2.12 spark-2.4.5

## SQOOP
FROM openjdk:8-slim-buster as sqoop

ARG HADOOP_VERSION
ENV JAVA_HOME=/usr/local/openjdk-8/
RUN mkdir -p /usr/share/man/man1
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/apache/sqoop.git
RUN cd sqoop \
    && sed -i "s/hadoop.version=.*/hadoop.version=$HADOOP_VERSION/" ivy/libraries.properties \
    && sed -i "s/hadoopVersion=.*/hadoopVersion=$HADOOP_VERSION/" gradle.properties \
    && ./gradlew package -x test -x realDocs -x compileTestJava -x doc -x javadoc \
    && cd build/sqoop-1.5.0-SNAPSHOT.bin__hadoop-$HADOOP_VERSION \
    && rm -r testdata src gradle config\
    && rm sqoop-test-1.5.0-SNAPSHOT.jar *.gradle *.bat *.properties build.xml gradlew

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
#RUN sed -i "s/tez.version=0.7.0/tez.version=$TEZ_VERSION/" $PIG_HOME/ivy/libraries.properties

# SQOOP
ENV SQOOP_HOME=/opt/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin
COPY --from=sqoop /sqoop/build/sqoop-1.5.0-SNAPSHOT.bin__hadoop-$HADOOP_VERSION $SQOOP_HOME
COPY sqoop-env-template.sh $SQOOP_HOME/conf
RUN cp /opt/hive/jdbc/hive-jdbc-2.3.7-standalone.jar $SQOOP_HOME/lib/
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.12.jar -P /opt/sqoop/lib && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz \
    | tar -xvz -C / && \
    mv /mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar $SQOOP_HOME/lib/ && \
    rm -r /mysql-connector-java-8.0.19

# PRESTO
# ADD presto-server-332.tar.gz /opt/
# RUN mv /opt/presto-server-332 /opt/presto
# RUN mkdir /opt/presto/etc
# COPY presto-etc /opt/presto/etc

# ENV PRESTO_HOME=/opt/presto

# COPY presto-cli-332-executable.jar /bin
# RUN mv /bin/presto-cli-332-executable.jar /bin/presto
# RUN chmod +x /bin/presto

# SPARK
ENV SPARK_DIST_CLASSPATH="$(hadoop --config /$HADOOP_CONF_DIR classpath)"
RUN mkdir /opt/spark-2.4.5
COPY --from=dl /spark-2.4.5 /opt/spark-2.4.5

COPY run.sh /
RUN chmod +x /run.sh

EXPOSE 8081 4040

CMD ["/run.sh"]