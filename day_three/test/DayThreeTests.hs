module Main (main) where

import Test.Tasty
import Test.Tasty.HUnit
import Flat (copied, mmaped)
import Naive (naive)

main :: IO ()
main = defaultMain tests

answer :: Int
answer = 8039

tests :: TestTree
tests = testGroup "day one" [
    testCase "naive" $ naive "./data.txt" >>= assertEqual "" answer,
    testCase "copied" $ copied "./data.txt" >>= assertEqual "" answer,
    testCase "mmaped" $ mmaped "./data.txt" >>= assertEqual "" answer
  ]