module Main (main) where

import Data.List.Split (splitOn)

isSafe :: [Int] -> Int
isSafe reactor = do
    let tailReactor = drop 1 reactor
        headReactor = init reactor
        deltas = zipWith (-) tailReactor headReactor
    if 0 `elem` deltas
        then 0
    else if all (between 1 3) deltas || all (between (-3) (-1)) deltas
        then 1
    else 0
    where between low high x = x >= low && x <= high

isSafeWithDampeners :: [Int] -> Int
isSafeWithDampeners reactor = finalSafetyCount
    where
      initialSafetyCount = isSafe reactor
      finalSafetyCount = case initialSafetyCount of
        1 -> 1
        _ -> maximum [ isSafe (take i reactor ++ drop (i + 1) reactor) | i <- [0 .. length reactor - 1] ]
    

main :: IO ()
main = do
    contents <- readFile "../../levels.txt"
    let levels = map (map read . splitOn " ") (lines contents) :: [[Int]]
    let safetyChecks = map isSafe levels
    let safeCount = sum safetyChecks
    print safeCount
    let safetyChecksDampened = map isSafeWithDampeners levels
    let safeCountDampened = sum safetyChecksDampened
    print safeCountDampened