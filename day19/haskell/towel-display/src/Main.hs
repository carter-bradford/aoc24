module Main (main) where

import Data.Char (isSpace)
import qualified Data.Set as Set
import Data.Array

load_towel_options :: String -> IO [String]
load_towel_options filePath = do
  contents <- readFile filePath
  let towels = splitOn ',' contents
  return towels

load_towel_displays :: String -> IO [String]
load_towel_displays filePath = do
  contents <- readFile filePath
  return (lines contents)

splitOn :: Char -> String -> [String]
splitOn _ "" = [""]
splitOn delimiter str =
  let (before, remainder) = span (/= delimiter) str
  in trim before : case remainder of
    [] -> []
    (_:xs) -> splitOn delimiter xs

trim :: String -> String
trim = f . f
  where f = reverse . dropWhile isSpace

canFormDisplay :: [(Int, [String])] -> String -> Int
canFormDisplay towelMap display =
  let wordsList = concatMap snd towelMap
      wordSet = Set.fromList wordsList
      n = length display
      dp = listArray (0, n) $ True :
           [ any (\j -> dp ! j && Set.member (take (i - j) (drop j display)) wordSet)
                 [0 .. i - 1]
           | i <- [1 .. n] ]
  in if dp ! n then 1 else 0

canFormNDisplay :: [(Int, [String])] -> String -> Int
canFormNDisplay towelMap display =
  let wordsList = concatMap snd towelMap
      wordSet = Set.fromList wordsList
      n = length display
      dp = listArray (0, n) $ 1 :
            [ sum [ dp ! j | j <- [0 .. i - 1], Set.member (take (i - j) (drop j display)) wordSet ]
            | i <- [1 .. n] ]
  in dp ! n

main :: IO ()
main = do
  towel_options <- load_towel_options "towels.txt"
  let towelMap = foldr (\towel acc -> let len = length towel in
                                      if len `elem` map fst acc
                                      then map (\(k, v) -> if k == len then (k, towel:v) else (k, v)) acc
                                      else (len, [towel]):acc) [] towel_options
  towel_displays <- load_towel_displays "towel_displays.txt"
  let results = map (\display -> (display, canFormDisplay towelMap display)) towel_displays

  let possibleDisplays = sum $ map snd results
  print possibleDisplays

  let part2Results = map (\display -> (display, canFormNDisplay towelMap display)) towel_displays
  let possibleNDisplays = sum $ map snd part2Results
  print possibleNDisplays


