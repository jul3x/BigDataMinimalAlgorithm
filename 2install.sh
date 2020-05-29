home=/home/students/inf/j/jp420564/
#sed -i '$ a . path.sh' $home/.bashrc

rm -rf "/tmp_local/hadoop.jp420564"
mkdir "/tmp_local/hadoop.jp420564"
cd "/tmp_local/hadoop.jp420564"

hdfs_dir="/tmp_local/hadoop.jp420564/hdfsdata"
cluster_dir_after="/tmp_local/hadoop.jp420564/cluster"

mkdir $hdfs_dir
mkdir $cluster_dir_after
tar -xvf ~/download/openjdk-8u41-b04-linux-x64-14_jan_2020.tar.gz -C $cluster_dir_after
tar -xvf ~/download/hadoop-2.7.7.tar.gz -C $cluster_dir_after
tar -xvf ~/download/spark-2.4.5-bin-hadoop2.7.tgz -C $cluster_dir_after

export JAVA_HOME=$cluster_dir_after/java-se-8u41-ri
export HADOOP_INSTALL=$cluster_dir_after/hadoop-2.7.7
export HADOOP_PREFIX=$HADOOP_INSTALL

JAVA_HOME_=/tmp_local/hadoop.jp420564/cluster/java-se-8u41-ri
HADOOP_INSTALL_=/tmp_local/hadoop.jp420564/cluster/hadoop-2.7.7

export PATH=$JAVA_HOME_/bin:$HADOOP_INSTALL_/bin:$HADOOP_INSTALL_/sbin:$PATH

etc_hadoop=${HADOOP_INSTALL_}/etc/hadoop

#hdfs_dir="${home}/hdfsdata"
master=$(head -n 1 ${home}/master)
cp $home/slaves_no_master $HADOOP_INSTALL/etc/hadoop/slaves

echo 
echo "***************************************************************************"
echo modifying ${HADOOP_INSTALL}/etc/hadoop/hadoop-env.sh
echo setting export JAVA_HOME=${JAVA_HOME}
echo "***************************************************************************"
sed -i -e "s|^export JAVA_HOME=\${JAVA_HOME}|export JAVA_HOME=$JAVA_HOME|g" ${HADOOP_INSTALL_}/etc/hadoop/hadoop-env.sh

cat <<EOF > ${etc_hadoop}/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://${master}:9123</value>
    <description>NameNode URI</description>
  </property>

</configuration>
EOF

cat <<EOF > ${etc_hadoop}/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>

  <property>
    <name>dfs.namenode.http-address</name>
    <value>${master}:50170</value>
  </property>

  <property>
    <name>dfs.secondary.http.address</name>
    <value>${master}:50190</value>
  </property>

  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file://${hdfs_dir}/datanode</value>
    <description>Comma separated list of paths on the local filesystem of a DataNode where it should store its blocks.</description>
  </property>

  <property>
    <name>dfs.datanode.max.locked.memory</name>
    <value>64000</value>
  </property>

  <property>
    <name>dfs.namenode.name.dir</name>
    <value>file://${hdfs_dir}/namenode</value>
    <description>Path on the local filesystem where the NameNode stores the namespace and transaction logs persistently.</description>
  </property>

  <property>
    <name>dfs.namenode.checkpoint.dir</name>
    <value>file://${hdfs_dir}/secondary_namenode</value>
  </property>


  <property>
    <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
    <value>false</value>
    <description>http://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/</description>
  </property>
</configuration>
EOF


cat <<EOF > ${etc_hadoop}/mapred-site.xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.cluster.local.dir</name>
        <value>file://${hdfs_dir}</value>
    </property>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>256</value>
    </property>
    <property>
        <name>mapreduce.map.java.opts</name>
        <value>-Xmx15384m</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>256</value>
    </property>
    <property>
        <name>mapreduce.reduce.java.opts</name>
        <value>-Xmx15384m</value>
    </property>
</configuration>
EOF


cat <<EOF > ${etc_hadoop}/yarn-site.xml
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
	<name>yarn.nodemanager.local-dirs</name>
	<value>file://${hdfs_dir}/nm_data</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>${master}:8132</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>${master}:8131</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>${master}:8130</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>${master}</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>${master}:8188</value>
    </property>

    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
   </property>
    <property>
	<name>yarn.nodemanager.resource.memory-mb</name>
	<value>3072</value>
   </property>
   <property>
	<name>yarn.scheduler.minimum-allocation-mb</name>
        <value>256</value>
   </property>
   <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>4096</value>
        <description>Max RAM-per-container https://stackoverflow.com/questions/43826703/difference-between-yarn-scheduler-maximum-allocation-mb-and-yarn-nodemanager</description>
   </property>
</configuration>
EOF



