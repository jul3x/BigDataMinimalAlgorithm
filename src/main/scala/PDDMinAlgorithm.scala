/* PDDMinAlgorithm.scala */
import org.apache.spark.sql.SparkSession

object PDDMinAlgorithm {
  def main(args: Array[String]) {
    val spark = SparkSession.builder.appName("Simple Application").getOrCreate()

    val in_file = spark.read.format("csv")
      .option("sep", ",")
      .option("inferSchema", "true")
      .option("header", "true")
      .load("small_dataset.csv")
      .na.drop().cache

    in_file.collect().mkString("\n");


    spark.stop()
  }
}