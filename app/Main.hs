module Main
  ( main
  ) where

import System.Environment

import Lib

main :: IO ()
main = getArgs >>= run
