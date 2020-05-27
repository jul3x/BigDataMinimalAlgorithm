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


    sorted_by_y.collect().foreach(i => println(i))


    spark.stop()
  }
}