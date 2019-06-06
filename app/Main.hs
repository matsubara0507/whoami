{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Main where

import           Control.Lens           ((^.))
import           Data.Extensible
import           Data.Extensible.GetOpt
import           Data.Maybe             (listToMaybe)
import           Data.Text              (Text, pack)
import qualified Data.Text.Encoding     as T
import qualified Data.Text.IO           as T
import           Data.Yaml              (ParseException, decodeEither',
                                         decodeFileEither)
import           System.IO              (stderr)
import           Whoami

main :: IO ()
main = withGetOpt "[options] [input-file]" opts $ \r args -> do
  let
    opts'= #input @= toInput args <: r
  config <- readInput opts'
  case config of
    Left err  -> T.hPutStrLn stderr (pack $ show err)
    Right conf -> do
      result <- run (opts' ^. #write) conf
      case result of
        Right txt -> writeOutput opts' txt
        Left err  -> T.hPutStrLn stderr (pack $ show err)
  where
    opts = #output @= outputOpt
        <: #write @= writeFormatOpt
        <: nil

type Options = Record
  '[ "input" >: Maybe FilePath
   , "output" >: Maybe FilePath
   , "write"  >: Format
   ]

data Format
  = JSONFormat
  | MDFormat
  deriving (Show, Eq)

toInput :: [String] -> Maybe FilePath
toInput = listToMaybe

outputOpt :: OptDescr' (Maybe FilePath)
outputOpt =
  optionReqArg (pure . listToMaybe) ['o'] ["output"] "FILE" "Write output to FILE instead of stdout."

writeFormatOpt :: OptDescr' Format
writeFormatOpt =
  optionReqArg toFormat ['t','w'] ["to","write"] "FORMAT" "Specify output format. default is `markdown`."
  where
    toFormat ("json":_)     = pure JSONFormat
    toFormat ("markdown":_) = pure MDFormat
    toFormat _              = pure MDFormat

readInput :: Options -> IO (Either ParseException Config)
readInput opt =
  case opt ^. #input of
    Just path -> decodeFileEither path
    Nothing   -> (decodeEither' . T.encodeUtf8) <$> T.getContents

writeOutput :: Options -> Text -> IO ()
writeOutput opts txt =
  case opts ^. #output of
    Just path -> T.writeFile path txt
    Nothing   -> T.putStrLn txt

run :: Format -> Config -> IO (Either ServiceException Text)
run MDFormat conf   = runServiceM conf $ toMarkdown =<< genInfo whoami
run JSONFormat conf = runServiceM conf $ toJsonText =<< genInfo whoami
