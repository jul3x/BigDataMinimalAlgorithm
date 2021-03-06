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

  def generateRows(tuple: (String, String, Int, Int, Int), prefix_of: Char):
      Seq[(String, (String, String, Int, Int, Int))] = {
    var prefix = ""

    var return_val = Seq[(String, (String, String, Int, Int, Int))]()
    for (c <- tuple._2) {
      if (c == prefix_of) {
        return_val = return_val :+ (prefix, tuple)
      }

      prefix = prefix :+ c
    }

    return_val
  }

  def sumElements(i: (Int, Iterable[(Int, String, Int, Int)])): (Int, Int, Int, Int) = {
    val first_element = i._2.iterator.next()
    var sum = 0

    for (row <- i._2) {
      sum = sum + row._1
    }

    (i._1, first_element._3, first_element._4, sum)
  }

  def main(args: Array[String]) {
    val spark = SparkSession.builder.appName("2D Point Counting").getOrCreate()

    val in_file = spark.read.format("csv")
      .option("sep", ",")
      .option("inferSchema", "true")
      .option("header", "true")
      .load(args(0))
      .na.drop().cache

    val number_of_elements = in_file.count()
    val binary_length = getBinaryLength(number_of_elements)
    println("Number of elements: " + number_of_elements)

    val sorted_by_x = in_file.orderBy("x", "y").rdd.zipWithIndex()
      .map(i => (toBinary(i._2, binary_length), i._1.getAs[Int](0), i._1.getAs[Int](1), i._1.getAs[Int](2))).cache

    val query_points = sorted_by_x.map(row => ("Q", row._1, row._2, row._3, row._4))
    val data_points = sorted_by_x.map(row => ("D", row._1, row._2, row._3, row._4))

    val keys_query_points = query_points.flatMap(row => generateRows(row, '0'))
    val keys_data_points = data_points.flatMap(row => generateRows(row, '1'))

    val all_points = keys_query_points.union(keys_data_points)
        .sortBy(obj => (obj._1, obj._2._5, obj._2._4), ascending = false).cache()

    val broadcast_last_bucket = spark.sparkContext.broadcast(
      all_points.mapPartitionsWithIndex((i, iter) => {
        val seq = iter.toSeq
        var number_of_data_points = 0
        var last_label = "x"

        if (seq.nonEmpty) {
          for (row <- seq) {
            last_label = row._1
          }

          for (row <- seq) {
            if (last_label == row._1 && row._2._1 == "D") {
              number_of_data_points = number_of_data_points + 1
            }
          }
        }

        Iterator((last_label, (i, number_of_data_points)))
      }).groupByKey().collect().toMap[String, Iterable[(Int, Int)]]
    )

    val count_in_each_partition = all_points.mapPartitionsWithIndex((index, iter) => {
          var result_seq = Seq[(Int, (Int, String, Int, Int))]()
          val seq = iter.toSeq
          if (seq.nonEmpty) {
            var number_of_data_points = 0
            var previous_label = seq.iterator.next._1

            if (broadcast_last_bucket.value.isDefinedAt(previous_label)) {
              val broadcasted_from_other_servers = broadcast_last_bucket.value(previous_label)

              for (server <- broadcasted_from_other_servers) {
                if (server._1 < index) {
                  number_of_data_points = number_of_data_points + server._2
                }
              }
            }

            for (row <- seq) {
              if (previous_label != row._1) {
                number_of_data_points = 0
              }

              if (row._2._1 == "D") {
                number_of_data_points = number_of_data_points + 1
              }
              else {
                result_seq = result_seq :+ (row._2._3, (number_of_data_points, row._1, row._2._4, row._2._5)) // ID, (Count, Label, x, y)
              }

              previous_label = row._1
            }
          }

          Iterator(result_seq)
        })

    val all_points_collected = count_in_each_partition
      .flatMap(i => i)
      .groupByKey()
      .map(sumElements)
      .collect()

    all_points_collected.foreach(i => println(i._1 + "(" + i._2 + ", " + i._3 + "): " + i._4 + " greater elements."))

    spark.stop()
  }
}
