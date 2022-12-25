module Main (main) where

import Library (copied, mmaped, naive)
import Test.Tasty
import Test.Tasty.HUnit (assertEqual, testCase)

main :: IO ()
main = defaultMain tests

answer :: Int
answer = 213159

tests :: TestTree
tests =
    testGroup
        "day one"
        [ testCase "naive" $ naive "./data.txt" >>= assertEqual "" answer
        , testCase "copied" $ copied "./data.txt" >>= assertEqual "" answer
        , testCase "mmaped" $ mmaped "./data.txt" >>= assertEqual "" answer
        ]