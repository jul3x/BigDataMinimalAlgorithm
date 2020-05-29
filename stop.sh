hadoop_dir="/tmp_local/hadoop.jp420564"
hdfs_dir="/tmp_local/hadoop.jp420564/hdfsdata"
cluster_dir="/tmp_local/hadoop.jp420564/cluster"

export JAVA_HOME=$cluster_dir/java-se-8u41-ri
export HADOOP_INSTALL=$cluster_dir/hadoop-2.7.7
export HADOOP_PREFIX=$HADOOP_INSTALL

JAVA_HOME_=/tmp_local/hadoop.jp420564/cluster/java-se-8u41-ri
HADOOP_INSTALL_=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7

export PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH

echo 
echo "***************************************************************************"
echo stop-yarn.sh
echo "***************************************************************************"
stop-yarn.sh

echo 
echo "***************************************************************************"
echo stop-dfs.sh
echo "***************************************************************************"
stop-dfs.sh

