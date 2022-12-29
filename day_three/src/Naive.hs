module Naive (naive) where

import Data.Char (ord)
import Data.List qualified as List

getPriority :: Char -> Int
getPriority c
    | 'a' <= c && c <= 'z' = ord c - ord 'a' + 1
    | otherwise            = ord c - ord 'A' + 27

splitMiddle :: [a] -> ([a], [a])
splitMiddle l = splitAt (length l `div` 2) l

-- chunk :: Int -> [a] -> [[a]]
-- chunk n = takeWhile (not . null) . map (take n) . iterate (drop n)

priorityOfCommonItem :: (String, String) -> Int
priorityOfCommonItem = getPriority . head . uncurry List.intersect

-- priorityOfBadge :: [String] -> Int
-- priorityOfBadge = getPriority . head . foldl1 intersect

-- naive :: IO Int
naive :: FilePath -> IO Int
naive source = do
    input <- lines <$> readFile source
    return $ sum $ map (priorityOfCommonItem . splitMiddle) input
