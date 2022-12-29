module Main (main) where

import Test.Tasty.Bench
import Flat (copied, mmaped)
import Naive (naive)


main :: IO ()
main = defaultMain [
    bench "naive" $ nfIO (naive "./data.txt"),
    bench "copied" $ nfIO (copied "./data.txt"),
    bench "mmaped" $ nfIO (mmaped "./data.txt")
  ]
