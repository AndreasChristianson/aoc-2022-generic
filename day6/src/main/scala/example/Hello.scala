package example
import scala.io.Source

// https://docs.scala-lang.org/tour/regular-expression-patterns.html
object Hello extends Greeting with App {

  val source = Source.fromFile("test.txt")
  for (line <- source.getLines())
    println(line)
  source.close()
}

trait Greeting {
  lazy val greeting: String = "hello"
}
