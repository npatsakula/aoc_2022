{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -O2 #-}

module Library (naive, copied, mmaped) where

import Data.ByteString qualified as BS
import Data.Text qualified as T
import Text.Read qualified as T
import Data.Text.IO qualified as T
import Data.Void (Void)
import Data.List (sort)
import Control.Monad (forM, when)
import Data.Vector.Algorithms.Intro qualified as Vector
import Data.Vector.Primitive.Mutable qualified as Vector
import FlatParse.Basic
import System.IO.MMap (mmapFileByteString)

naive :: String -> IO Int
{-# INLINEABLE naive #-}
naive path = do
  source <- T.readFile path
  let blocks = T.splitOn "\n" <$> T.splitOn "\n\n" source
  parsed <-
    forM blocks $
      mapM
        ( \l -> do
            case T.readEither $ T.unpack l of
              Right i -> return i
              Left e -> fail e
        )
  let sum_blocks = reverse . sort $ sum <$> parsed
  return $ sum $ Prelude.take 3 sum_blocks

copied :: String -> IO Int
{-# INLINEABLE copied #-}
copied path = BS.readFile path >>= flat

mmaped :: String -> IO Int
{-# INLINEABLE mmaped #-}
mmaped path = mmapFileByteString path Nothing >>= flat

flat :: BS.ByteString -> IO Int
{-# INLINE flat #-}
flat source = do
  case runParser blocksMax source of
    OK m _ -> m
    Fail -> fail "Failed to parse data."

blockSum :: Parser Void Int
{-# INLINE blockSum #-}
blockSum = chainl (+) (return 0) (getAsciiDecimalInt <* $(getCharOf '\n')) <* $(getCharOf '\n')

blocksMax :: Parser Void (IO Int)
{-# INLINE blocksMax #-}
blocksMax = do
  state <- chainl add (return emptyParseState) blockSum
  return $ state >>= maxThree
  where
    add :: IO ParseState -> Int -> IO ParseState
    add st v = st >>= \s -> addInfo s v

newtype ParseState = ParseState (Vector.IOVector Int)

emptyParseState :: IO ParseState
{-# INLINE emptyParseState #-}
emptyParseState = ParseState <$> Vector.replicate 4 (0 :: Int)

addInfo :: ParseState -> Int -> IO ParseState
{-# INLINE addInfo #-}
addInfo (ParseState inner) v = do
  lower <- Vector.read inner 0
  when (v > lower) $ Vector.write inner 0 v >> Vector.sort inner
  return $ ParseState inner

maxThree :: ParseState -> IO Int
{-# INLINE maxThree #-}
maxThree (ParseState inner) = Vector.foldl (+) 0 $ Vector.slice 1 3 inner
