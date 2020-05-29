# BigDataMinimalAlgorithm
Second big task for Big Data course at MIMUW.  

Implementation of minimal parallel algorithm for checking how many points in the given dataset are greater (by all coordinates) than given one. The assumption is that there is approximately the same number of query points and data points.

Implementation consists of two versions - for 2D and 3D points datasets implemented in **Spark 2.4.5** and prepared for being launched on top of **YARN** and **HDFS**.

Datasets are generated using `generate_data.sh` and `generate_data_3d.sh` scripts.

Theoretical background of the algorithm can be found in a paper https://dl.acm.org/doi/pdf/10.1145/3070607.3075961  

*Notice: Due to collisions, many of ports of HDFS setup had to be changed, so scripts may not work on any other cluster.*

## Cluster setup:
   ### Downloading
   * Run `1download.sh` script to download open-jdk, hadoop and spark.
   ### Installing hdfs
   * Run `2install.sh` and then `3copy.sh` scripts to install hadoop and copy spark dirs on desired computers (computers IPs should be described in `~/slaves_with_master`, `~/slaves_no_master` and `~/master` files).
   ### Running hdfs
   * Run `start.sh` to run *HDFS* on a cluster (key-based authentication required).
   ### Uploading dataset
   * Run `upload_to_hdfs.sh` to upload datasets to hdfs.
## Running application
   * 2D case:
      * Go to `2D` directory.  
      * Run `build_app.sh` script to make *.jar file in target/scala-2.11 dir (pddminalgorithm_2.11-0.1.jar)
      * Run `start_app.sh` script to run application on YARN with standard `dataset.csv`. Due to a long runtime - dataset can be changed to prepared sample dataset `small_dataset.csv` by changing filepath in `start_app.sh` file. Results are shown in stdout (possibly on workers logs).
   * 2D case:
      * Go to `3D` directory.  
      * Run `build_app.sh` script to make *.jar file in target/scala-2.11 dir (pddminalgorithm3d_2.11-0.1.jar)
      * Run `start_app.sh` script to run application on YARN with standard `dataset_3d.csv`. Due to a long runtime - dataset can be changed to prepared sample dataset `small_dataset_3d.csv` by changing filepath in `start_app.sh` file. Results are shown in stdout (possibly on workers logs).
   * If you work on a different setup it may be needed to change the ports of HDFS in `start_app.sh` scripts.
   * In both cases, there are `sequential_checker.py` scripts written in **Python 3**. They can be used for comparison between the results of parallel algorithm and the most trivial one.
   For obvious reasons those scripts can be only used with smaller versions of datasets.
## End of work
   * Run `stop.sh` to close the whole hdfs.
