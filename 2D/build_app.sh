#!/bin/bash


JAVA_HOME_=/tmp_local/hadoop.jp420564/cluster/java-se-8u41-ri
HADOOP_INSTALL_=/tmp_local/hadoop.jp420564/cluster/hadoop-2.8.5

export PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH

source env.sh

sbt package
