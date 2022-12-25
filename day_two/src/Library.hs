{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -O2 -fllvm #-}

module Library (naive, copied, mmaped, euclidReminder) where

import Data.ByteString qualified as BS
import Data.Void (Void)
import Control.Monad (void)
import FlatParse.Basic qualified as FP
import FlatParse.Basic.Strings as FP (getChar, getCharOf)
import System.IO.MMap (mmapFileByteString)
import Data.Char (ord)

euclidReminder :: Int -> Int -> Int
{-# INLINE euclidReminder #-}
euclidReminder left right = if reminder < 0
    then if right > 0
        then reminder + right
        else reminder - right
    else reminder
  where
    reminder = left `rem` right

parseLine :: FP.Parser Void (Char, Char)
{-# INLINE parseLine #-}
parseLine = do
    left <- FP.getChar
    void $ $(FP.getCharOf ' ')
    right <- FP.getChar
    void $ $(FP.getCharOf '\n')
    return (left, right)

flat :: MonadFail m => BS.ByteString -> m Int
{-# INLINE flat #-}
flat source = case FP.runParser parser source of
    FP.OK r _ -> return r
    FP.Fail -> fail "Failed to parse."
  where
    parser = FP.chainl add (return 0) parseLine

    add acc (left, right) = acc + current
        where
            (l, r) = convertLine left right
            -- current = 1 + r + 3 * (euclidReminder (1 + r - l) 3)
            current = 1 + r * 3 + (2 + l + r) `rem` 3

    leftShift = ord 'A'
    rightShift = ord 'X'
    convertLine left right = (ord left - leftShift, ord right - rightShift)

copied :: FilePath -> IO Int
{-# INLINABLE copied #-}
copied path = do
    source <- BS.readFile path
    flat source

mmaped :: FilePath -> IO Int
{-# INLINABLE mmaped #-}
mmaped path = do
    source <- mmapFileByteString path Nothing
    flat source

naive :: FilePath -> IO Int
{-# INLINABLE naive #-}
naive path = do
    input <- parseInput <$> readFile path
    return $ sum $ map (play [3, 1, 2] [0, 3, 6] 1) input
  where
    parseInput :: String -> [(Int, Int)]
    {-# INLINE parseInput #-}
    parseInput = map (\s -> (ord (head s) - ord 'A', ord (s !! 2) - ord 'X')) . lines
    
    play :: [Int] -> [Int] -> Int -> (Int, Int) -> Int
    {-# INLINE play #-}
    play ptsRes ptsAct cyc (p1, p2) = ptsAct !! p2 + cycle ptsRes !! (p1 + cyc * p2)