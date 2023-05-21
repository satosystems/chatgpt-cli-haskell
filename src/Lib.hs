{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( run
  ) where

import Control.Monad
import Data.Aeson
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as LB
import Data.Maybe
import Data.String.Conversions
import GHC.Generics
import Network.Http.Client
import System.Console.Haskeline
import System.Directory
import System.Environment
import System.Exit
import System.IO
import qualified System.IO.Streams as IOS

newtype Config =
  Config
    { apiKey :: String
    }
  deriving (Generic, Read, Show)

instance ToJSON Config

instance FromJSON Config

exitFailure' :: String -> IO ()
exitFailure' msg = do
  hPutStrLn stderr $ "\ESC[31m" ++ msg ++ "\ESC[0m"
  void exitFailure

getConfigFile :: IO FilePath
getConfigFile = do
  mHome <- lookupEnv "HOME"
  let home = fromMaybe "" mHome
  return $ home ++ "/.chat"

setup :: FilePath -> IO ()
setup configFile = do
  mApiKey <-
    runInputT defaultSettings $
    getPassword (Just '*') "Input your OPENAP_API_KEY: "
  case mApiKey of
    Nothing -> exitFailure' "Oops!"
    Just ak -> do
      h <- openBinaryFile configFile WriteMode
      LB.hPut h $ encode $ Config ak
      hFlush h
      hClose h

run :: [String] -> IO ()
run args = do
  configFile <- getConfigFile
  exists <- doesFileExist configFile
  not exists `when` setup configFile
  jsonData <- LB.readFile configFile
  case (null args, decode jsonData) of
    (True, _) -> exitFailure' "Please chat message to CLI options"
    (_, Nothing) -> exitFailure' "Cannot read config file: ~/.chat"
    (_, Just (Config ak)) -> do
      let content = (show . unwords) args
      ctx <- baselineContextSSL
      c <- openConnectionSSL ctx "api.openai.com" 443
      let q =
            buildRequest1 $ do
              http POST "/v1/chat/completions"
              setContentType "application/json"
              setHeader "Authorization" $ cs $ "Bearer " ++ ak
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
