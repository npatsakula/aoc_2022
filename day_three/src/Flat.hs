{-# OPTIONS_GHC -O2 -fllvm #-}
{-# OPTIONS_GHC -Wno-unused-top-binds #-}

{-# LANGUAGE TemplateHaskell #-}

module Flat (copied, mmaped, flattest) where

import Data.Text qualified as T
import Data.ByteString.Char8 qualified as BS
import Data.Void (Void)
import FlatParse.Basic qualified as FP
import System.IO.MMap (mmapFileByteString)
import Data.Char (ord)
import Data.Function ((&))

type Parser a = FP.Parser Void a

linesP :: Parser [T.Text]
{-# INLINE linesP #-}
linesP = FP.some $ T.pack <$> FP.some (FP.satisfy (/= '\n')) <* FP.skip 1

flat :: Parser Int
{-# INLINE flat #-}
flat = let
    splitHalf l = T.splitAt (T.length l `div` 2) l

    helper left right
      = T.filter (`T.elem` left) right
      & T.unpack
      & fmap (\c -> if ord c >= ord 'a'
            then (ord c - ord 'a') + 1
            else (ord c - ord 'A') + 27
          )
      & Prelude.head
  in
    do
        ls <- linesP
        return $ sum $ uncurry helper . splitHalf <$> ls

flattest :: Parser Int
{-# INLINE flattest #-}
flattest = let
    line = FP.byteStringOf $ FP.many_ $ FP.satisfy_ (/= '\n')

    splitLine l = BS.splitAt (BS.length l `div` 2) l

    helper (left, right)
      = BS.filter (`BS.elem` left) right
      & BS.unpack
      & fmap (\c -> if ord c >= ord 'a'
            then (ord c - ord 'a') + 1
            else (ord c - ord 'A') + 27
          )
      & Prelude.head

    accumulator acc v = acc + helper ( splitLine v)
  in do
    FP.chainl accumulator (return 0) (line <* $(FP.getCharOf '\n'))

runP :: MonadFail m => BS.ByteString -> m Int
{-# INLINE runP #-}
runP source =
    case FP.runParser flattest source of
        FP.OK r _ -> return r
        FP.Fail -> fail "Filed to parse text."

copied :: FilePath -> IO Int
{-# INLINE copied #-}
copied path = do
    source <- BS.readFile path
    runP source

mmaped :: FilePath -> IO Int
{-# INLINE mmaped #-}
mmaped path = do
    source <- mmapFileByteString path Nothing
    runP source
