{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ImportQualifiedPost #-}

module Main (main) where

import Library qualified
import Options.Applicative

newtype Opt = Opt {path :: String}

opt :: Parser Opt
opt =
  Opt
    <$> strOption
      ( long "path"
          <> short 'p'
          <> metavar "PATH"
          <> help "Path to source data"
          <> value "./data.txt"
      )

main :: IO ()
main = do
  Opt {path} <- execParser opts
  result <- Library.mmaped path
  print result
  where
    opts = info (opt <**> helper) fullDesc
