source env.sh

export HADOOP_CONF_DIR=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7/etc/hadoop/
export YARN_CONF_DIR=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7/etc/hadoop/
export SPARK_LOCAL_DIRS=/tmp_local/hadoop.jp420564/cluster/spark_data
export LOCAL_DIRS=/tmp_local/hadoop.jp420564/cluster/spark_data

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR

JAVA_HOME_=/tmp_local/hadoop.jp420564/cluster/java-se-8u41-ri
HADOOP_INSTALL_=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7

hdfs_ip=$(head -n 1 ~/master)

/tmp_local/hadoop.jp420564/cluster/spark-2.4.5-bin-hadoop2.7/bin/spark-submit \
    --class PDDMinAlgorithm3D \
    --master yarn \
    --deploy-mode cluster \
    --conf java.io.tmpdir=/tmp_local/hadoop.jp420564/spark_data \
    --conf spark.local.dir=/tmp_local/hadoop.jp420564/spark_data \
    --conf spark.yarn.appMasterEnv.JAVA_HOME=$JAVA_HOME_ \
    --conf spark.yarn.appMasterEnv.HADOOP_INSTALL=$HADOOP_INSTALL_ \
    --conf spark.yarn.appMasterEnv.PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH \
    --conf spark.executorEnv.JAVA_HOME=$JAVA_HOME_ \
    --conf spark.executorEnv.HADOOP_INSTALL=$HADOOP_INSTALL_ \
    --conf spark.executorEnv.PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH \
    target/scala-2.11/pddminalgorithm3d_2.11-0.1.jar "hdfs://$hdfs_ip:9123/user/points/dataset_3d.csv"

