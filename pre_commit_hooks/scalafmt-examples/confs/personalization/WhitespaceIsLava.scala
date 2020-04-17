import scala.concurrent.ExecutionContext

/**
  * Many engineers prefer that adding a param does not require changing any other lines. It matters for git blame.
  *
  * Want to test your changes with the formatter? Run ` ./pre_commit_hooks/scalafmt-examples/scalafmt-examples.sh`
  * from the root of repository checkout.
  *
  * @param foo stringy string
  * @param bar inty int
  * @param ordering$T enforces pecking order
  * @param numeric$T unnecessary, but sure!
  * @param executionContext can you really do anything without one?
  * @param materializer absolute [[Unit]] of a construct
  * @tparam T "T" is to type params, what "i" is to for loops.
  */
class WhitespaceIsLava[T <: Any : Ordering : Numeric](
  foo: String = "zomg",
  val bar: Int = 1
)(implicit
  executionContext: ExecutionContext,
  materializer: Unit
) extends Comparable[WhitespaceIsLava[T]]
  with Serializable {
  private val fieldOne: String = ""
  private val fieldTwo: Unit = Unit
  private val fieldThree: Int = 42
  private implicit val fieldFour: NullPointerException = new NullPointerException
  override def compareTo(o: WhitespaceIsLava[T]): Int = this.bar.compareTo(o.bar)
  override def toString: String =
    new StringBuilder()
      .append("yOu")
      .append(" ")
      .append("ShOuLd")
      .append("iMpLeMeNt")
      .append(" ")
      .append("A")
      .append(" ")
      .append("tOsTrInG")
      .result()
  def line81: String = "This line is exactly" + "81 chars long after formatting"

  def line121: String =
    "This line is exactly" + "121 chars long after formatting" + " Always happy when with long lines!"

  def caseLove(love: Int): Boolean = love match {
    case 8675309 => true
    case 42 => true
    case 0 => true
    case _ => false
  }

  def iLikeLongMethodsAndCannotLie(
    big: java.util.concurrent.ScheduledThreadPoolExecutor,
    long: java.util.concurrent.ScheduledThreadPoolExecutor,
    param: java.util.concurrent.ScheduledThreadPoolExecutor,
    names: java.util.concurrent.ScheduledThreadPoolExecutor
  ): Unit = Unit
  def shortMethod(): Unit = Unit
  def shortMethod(argOne: String): Unit = Unit

  def shortMethod(
    argOne: String,
    argTwo: String
  ): Unit = Unit
  def multipleArgLists(argOne: String)(argTwo: String)(argThree: String): Unit = Unit
  def multipleArgLists(argOne: String)(argTwo: String)(argThree: String)(implicit argFour: String): Unit = Unit

  /** DocString should have a blank line above it. */
  def shortMethod(): Unit = Unit

  /** Redundant braces removes braces */
  def bracesGone(): Unit = {
    Unit
  }
}
