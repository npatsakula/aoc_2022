module Main (main) where

import Test.Tasty.Bench
import Library (naive, copied, mmaped)


main :: IO ()
main = defaultMain [
    bench "naive" $ nfIO (naive "./data.txt"),
    bench "copied" $ nfIO (copied "./data.txt"),
    bench "mmaped" $ nfIO (mmaped "./data.txt")
  ]
