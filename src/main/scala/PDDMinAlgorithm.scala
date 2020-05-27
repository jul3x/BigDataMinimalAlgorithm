/* PDDMinAlgorithm.scala */
import org.apache.spark.sql.{Row, SparkSession}

import scala.math

object PDDMinAlgorithm extends Serializable {
  def toBinary(l: Long, length: Int): String = {
     val value = l.toBinaryString
     "0" * (length - value.length()) + value
  }

  def getBinaryLength(l: Long): Int = {
    var log2 = (x: Double) => math.log10(x)/math.log10(2.0)
    math.ceil(log2(l)).toInt
  }

  def generateRows(tuple: (String, String, Any, Any, Any), prefix_of: Char):
      Seq[(String, (String, String, Any, Any, Any))] = {
    var prefix = ""

    var return_val = Seq[(String, (String, String, Any, Any, Any))]()
    for (c <- tuple._2) {
      if (c == prefix_of) {
        return_val = return_val :+ (prefix, tuple)
      }

      prefix = prefix :+ c
    }

    return_val
  }

  def main(args: Array[String]) {
    val spark = SparkSession.builder.appName("Simple Application").getOrCreate()

    val in_file = spark.read.format("csv")
      .option("sep", ",")
      .option("inferSchema", "true")
      .option("header", "true")
      .load("small_dataset.csv")
      .na.drop().cache

    val number_of_elements = in_file.count()
    val binary_length = getBinaryLength(number_of_elements)
    println("Number of elements! : " + number_of_elements)

    val sorted_by_x = in_file.orderBy("x").rdd.zipWithIndex()
      .map(i => (toBinary(i._2, binary_length), i._1.get(0), i._1.get(1), i._1.get(2))).cache

    val sorted_by_y = sorted_by_x.sortBy(_._4.toString.toInt).zipWithIndex()
      .map(i => (i._1._1 + toBinary(i._2, binary_length), i._1._2, i._1._3, i._1._4)).cache

    val query_points = sorted_by_y.map(row => ("Q", row._1, row._2, row._3, row._4))
    val data_points = sorted_by_y.map(row => ("D", row._1, row._2, row._3, row._4))

    val keys_query_points = query_points.flatMap(row => generateRows(row, '0'))
    val keys_data_points = data_points.flatMap(row => generateRows(row, '1'))

    val all_points = keys_query_points.union(keys_data_points).groupByKey()

    all_points.collect().foreach(i => println(i))


    spark.stop()
  }
}