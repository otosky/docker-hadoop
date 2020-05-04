#!/bin/bash

$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR historyserver