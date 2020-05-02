#!/bin/bash

mkdir -p /tmp/tez-$TEZ_VERSION
tar -xvzf /tmp/tez/tez-$TEZ_VERSION.tar.gz -C /tmp/tez-$TEZ_VERSION
hdfs dfs -mkdir -p /apps/
hdfs dfs -copyFromLocal /tmp/tez-$TEZ_VERSION /apps/

rm -r /tmp/tez-$TEZ_VERSION
rm -r /tmp/tez

hdfs dfs -mkdir -p /apps/spark
hdfs dfs -copyFromLocal $SPARK_HOME/jars /apps/spark

tail -F /dev/null