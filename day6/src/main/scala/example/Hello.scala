package example
import scala.io.Source
import scala.util.control.Breaks._

object Hello extends App {
  val source = Source.fromFile("input.txt")
  for (line <- source.getLines()) {
    println(line)
    var i = 13;
    breakable {
      while (true) {
        i = i + 1
        if (line.subSequence(i - 14, i).chars().distinct().count() == 14) {
          println(i)
          break
        }
      }
    }

  }
  source.close()
}
