DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR

../spark-2.4.5-bin-hadoop2.7/bin/spark-submit \
    --master local[4] \
    --class "PDDMinAlgorithm3D" \
    target/scala-2.11/pddminalgorithm3d_2.11-0.1.jar ../small_dataset_3d.csv

