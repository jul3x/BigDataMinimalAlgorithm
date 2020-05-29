source env.sh

hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/points
hdfs dfs -put dataset.csv /user/points
hdfs dfs -put small_dataset.csv /user/points
hdfs dfs -put dataset_3d.csv /user/points
hdfs dfs -put small_dataset_3d.csv /user/points
