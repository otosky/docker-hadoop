[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/big-data-europe/Lobby)

# Hadoop Docker

Docker images for running a Hadoop cluster & associated tools.  Adapted from [big-data-europe/docker-hadoop](https://github.com/big-data-europe/docker-hadoop) to have leaner images and updated dependency versions.

## Software Versions

| Application | Version |
|:-----------:|:-------:|
| Hadoop      |  2.10.0 |
| Tez         |  0.9.2  |
| Pig         |  0.17.0 |
| Hive        |  2.3.7  |
| HBase       |  1.5.0  |
| Sqoop       |  1.4.7  |
| Spark       |  2.4.5  |

## Quick Start

To deploy an example HDFS cluster, run:
```bash
docker-compose up -d
```

To add Hive/HBase afterwards, run:
```bash
docker-compose -f hive_deploy/docker-compose.yml up -d
docker-compose -f hbase_deploy/docker-compose.yml up -d
```

Enter into the client container to run commands on the cluster:
```bash
docker exec -it hadoop-client bash
```

The inevitable word-count example to test Tez:
```bash
hadoop jar $TEZ_HOME/tez-examples-0.9.2.jar orderedwordcount /apps/tez-0.9.2/LICENSE /tests/

# the output can be found in HDFS via
hdfs dfs -ls /tests

# view output 
hdfs dfs -cat /tests/part-rest-of-filename-here
```

Test Spark on YARN:
```bash
spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client $SPARK_HOME/examples/jars/spark-examples*.jar

# NOTE: you can also use "cluster" as a --deploy-mode
```

## Web UIs

Ports are exposed for the relevant Web UIs:

* Namenode: http://localhost:50070/
* YARN Resource manager: http://localhost:8088/
* History server: http://localhost:8188/
* Nodemanager: http://localhost:8042/
* Hive: http://localhost:10002/
* HBase: http://localhost:16010/
* Spark: http://localhost:4040/
* *Note: If running Spark under YARN, the CSS formatting for the UI at port 4040 is broken. You should instead visit via the YARN UI.*

**Note: The UIs will try to reconcile the hostname in hyperlinks as the relevant container names, e.g. "resourcemanager:8088/..." for YARN. This is kind of annoying if you want to bounce around the logs. The hack I've come up with in the meantime is to use the included tampermonkey JS-script to change all the hrefs to reference "localhost".  This doesn't always work if the redirects are proxied, however.**

## Configure Environment Variables

The configuration parameters can be specified in the hadoop.env file or as environmental variables for specific services (e.g. namenode, datanode etc.):
```
  CORE_CONF_fs_defaultFS=hdfs://namenode:8020
```

CORE_CONF corresponds to core-site.xml. fs_defaultFS=hdfs://namenode:8020 will be transformed into:
```
  <property><name>fs.defaultFS</name><value>hdfs://namenode:8020</value></property>
```
To define dash inside a configuration parameter, use triple underscore, such as YARN_CONF_yarn_log___aggregation___enable=true (yarn-site.xml):
```
  <property><name>yarn.log-aggregation-enable</name><value>true</value></property>
```

The available configurations are:
* /etc/hadoop/core-site.xml CORE_CONF
* /etc/hadoop/hdfs-site.xml HDFS_CONF
* /etc/hadoop/yarn-site.xml YARN_CONF
* /etc/hadoop/httpfs-site.xml HTTPFS_CONF
* /etc/hadoop/kms-site.xml KMS_CONF
* /etc/hadoop/mapred-site.xml  MAPRED_CONF

If you need to extend some other configuration file, refer to base/entrypoint.sh bash script.