{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( run
  ) where

import Control.Monad
import qualified Data.ByteString as B
import Data.String.Conversions
import Network.Http.Client
import qualified System.IO.Streams as IOS

run :: [String] -> IO ()
run args = do
  let apiKey = head args
  let content = (show . unwords . tail) args
  ctx <- baselineContextSSL
  c <- openConnectionSSL ctx "api.openai.com" 443
  let q =
        buildRequest1 $ do
          http POST "/v1/chat/completions"
          setContentType "application/json"
          setHeader "Authorization" $ cs $ "Bearer " ++ apiKey
  sendRequest c q $
    simpleBody $
    cs $
    "{\"model\": \"gpt-3.5-turbo\",\"messages\": [{\"role\": \"user\", \"content\": " ++
    content ++ "}]}"
  receiveResponse
    c
    (\_ is -> do
       m <- IOS.read is
       forM_ m B.putStr)
  closeConnection c
