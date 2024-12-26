
import scala.io.Source

def readRules(filePath: String): Map[Int, Set[Int]] = {
  val source = Source.fromFile(filePath)
  val rules = source.getLines()
    .map(_.split('|').map(_.toInt))
    .foldLeft(Map[Int, Set[Int]]()) { (acc, rule) =>
      val key = rule(0)
      val value = rule(1)
      acc + (key -> (acc.getOrElse(key, Set()) + value))
    }
  source.close()
  rules
}

def readUpdates(filePath: String): List[List[Int]] = {
  val source = Source.fromFile(filePath)
  val updates = source.getLines().map(_.split(',').map(_.toInt).toList).toList
  source.close()
  updates
}

def isSorted(updates: List[Int], rules: Map[Int, Set[Int]]): Boolean = {
  updates.zipWithIndex.forall { case (current, idx) =>
    !rules.get(current).exists(values =>
      values.exists(value => updates.take(idx).contains(value))
    )
  }
}

def sortUpdate(updates: List[Int], rules: Map[Int, Set[Int]]): List[Int] = {
  updates.zipWithIndex.foldLeft(List[Int]()) { case (acc, (current, idx)) =>
    val afterPages = rules.getOrElse(current, Set())
    val insertIndex = if (afterPages.isEmpty) acc.length else acc.indexWhere(afterPages.contains) match {
      case -1 => acc.length
      case i => i
    }
    if (insertIndex < idx) {
      acc.take(insertIndex) ++ List(current) ++ acc.drop(insertIndex)
    } else {
      acc ++ List(current)
    }
  }
}

@main def page_sorter(): Unit =
  println("I'm your fancy page sorter")
  val rules = readRules("/Users/carterbradford/tech-stuff/aoc-2024/day5/rules.txt")
  val updates = readUpdates("/Users/carterbradford/tech-stuff/aoc-2024/day5/updates.txt")
  val middleValueSum = updates.foldLeft(0) { (acc, update) =>
    if (isSorted(update, rules)) acc + update(update.length / 2)
    else acc
  }

  val unsorted = updates.filterNot(update => isSorted(update, rules))
  val sorted = unsorted.map(update => sortUpdate(update, rules))
  val correctedMiddleSum = sorted.foldLeft(0) { (acc, update) =>
    acc + update(update.length / 2)
  }


  println(middleValueSum)
  println(correctedMiddleSum)





  



