home=/home/students/inf/j/jp420564/
hadoop_dir="/tmp_local/hadoop.jp420564"
hdfs_dir="/tmp_local/hadoop.jp420564/hdfsdata"
cluster_dir="/tmp_local/hadoop.jp420564/cluster"
code_dir="${home}/SortAvroRecord"

rm -fr $hdfs_dir
mkdir $hdfs_dir
mkdir $hdfs_dir/namenode
mkdir $hdfs_dir/datanode
mkdir $hdfs_dir/secondary_namenode
mkdir $hdfs_dir/nm_data
mkdir $hdfs_dir/spark_data

user=jp420564
cd $home

export JAVA_HOME=$cluster_dir/java-se-8u41-ri
export HADOOP_INSTALL=$cluster_dir/hadoop-2.7.7
export HADOOP_PREFIX=$HADOOP_INSTALL

JAVA_HOME_=/tmp_local/hadoop.jp420564/cluster/java-se-8u41-ri
HADOOP_INSTALL_=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7

export PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH

while read name
do
  echo "============================== syncing to:" $name "==================================="
  
  ssh -n $user@$name rm -fr "/tmp_local/hadoop.jp420564"
  ssh -n $user@$name mkdir "/tmp_local/hadoop.jp420564"
  ssh -n $user@$name mkdir $hdfs_dir
  ssh -n $user@$name mkdir $hdfs_dir/datanode
  ssh -n $user@$name mkdir $hdfs_dir/secondary_namenode
  ssh -n $user@$name mkdir $hdfs_dir/spark_data
  ssh -n $user@$name mkdir $hdfs_dir/nm_data
  rsync -zrvhae ssh $cluster_dir $user@$name:$hadoop_dir
  rsync -zrvhae ssh $hdfs_dir $user@$name:$hadoop_dir


done < slaves_no_master

while read name
do
  echo "============================== syncing sources to:" $name "==================================="
  
  rsync -zrvhae ssh $code_dir $user@$name:
done < slaves_no_master

echo 
echo "***************************************************************************"
echo hdfs namenode -format
echo "***************************************************************************"
# Format the namenode directory (DO THIS ONLY ONCE, THE FIRST TIME)
hdfs namenode -format
