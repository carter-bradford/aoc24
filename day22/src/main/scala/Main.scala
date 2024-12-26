object Main:

    def mix(x: Long, y: Long): Long =
        x ^ y

    def prune(x: Long): Long =
        x % 16777216

    def step1(secret: Long): Long =
        prune(mix(secret * 64, secret))

    def step2(secret: Long): Long =
        prune(mix(secret / 32L, secret))

    def step3(secret: Long): Long =
        prune(mix(secret * 2048, secret))

    def getNextSecretNumber(secret: Long): Long =
        step3(step2(step1(secret)))

    def get2000thSecretNumber(secret: Long): Long = {
      return (1 to 2000).foldLeft(secret)((acc, _) => getNextSecretNumber(acc))
    }

    // Slow and could definitely be optimized
    def getCosts(secret: Long): List[(Long, Int, List[Int])] = {
        (1 to 2000).foldLeft((secret, List[(Long, Int, List[Int])](), List[Int]()))((acc, _) => {
            val nextSecret = getNextSecretNumber(acc._1)
            val nextCost = (nextSecret % 10).toInt
            val nextDiff = nextCost - (acc._1 % 10).toInt
            val diffs = (acc._3 :+ nextDiff).takeRight(4)
            (nextSecret, acc._2 :+ (nextSecret, nextCost, diffs), diffs)
        })._2
    }

    @main
    def main =
        val source = scala.io.Source.fromFile("secrets.txt")

        try {
            val secrets = source.getLines().map(_.toLong).toList
            val finalSecrets =
                secrets.map(get2000thSecretNumber).sum

            val costs =secrets.map(getCosts).toList

            var costMap = Map[List[Int], Int]()
            costs.foreach(costList => {
                var sequeneces_seen = List{List[Int]()}
                costList.foreach(cost => {
                    if (cost._3.size == 4 && !sequeneces_seen.contains(cost._3)) {
                        val key = cost._3
                        sequeneces_seen = sequeneces_seen :+ key
                        val value = cost._2
                        val currentCost = costMap.getOrElse(key, 0)
                        costMap = costMap.updated(key, currentCost + value)
                    }
                })
            })
            println(finalSecrets)
            println(costMap.values.max)
            
        } finally {
            source.close()
        }
