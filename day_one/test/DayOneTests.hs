module Main (main) where

import Test.Tasty
import Test.Tasty.HUnit
import Library (naive, copied, mmaped)

main :: IO ()
main = defaultMain tests

answer :: Int
answer = 213159

tests :: TestTree
tests = testGroup "day one" [
    testCase "naive" $ naive "./data.txt" >>= assertEqual "" answer,
    testCase "flat" $ copied "./data.txt" >>= assertEqual "" answer,
    testCase "mmaped" $ mmaped "./data.txt" >>= assertEqual "" answer
  ]