module Main where

import           Paths_whoami           (version)
import           RIO
import qualified RIO.ByteString         as B

import           Data.Extensible
import           Data.Extensible.GetOpt
import           Data.Version           (Version)
import qualified Data.Version           as Version
import           Data.Yaml              (ParseException, decodeEither',
                                         decodeFileEither)
import           Development.GitRev
import           Whoami

main :: IO ()
main = withGetOpt "[options] [input-file]" opts $ \r args ->
  if r ^. #version then
    B.putStr $ fromString (showVersion version) <> "\n"
  else do
    let opts' = #input @= toInput args <: r
    runCmd opts' >>= \case
      Left err  -> hPutBuilder stderr (fromString $ show err <> "\n")
      Right txt -> writeOutput opts' txt
  where
    runCmd opts' = readInput opts' >>= \case
      Left err   -> pure $ Left (ReadConfigException $ tshow err)
      Right conf -> run (opts' ^. #write) conf
    opts = #output  @= outputOpt
        <: #write   @= writeFormatOpt
        <: #version @= versionOpt
        <: nil

type Options = Record
  '[ "input"   >: Maybe FilePath
   , "output"  >: Maybe FilePath
   , "write"   >: Format
   , "version" >: Bool
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
    Nothing   -> decodeEither' <$> B.getContents

writeOutput :: Options -> Text -> IO ()
writeOutput opts txt =
  case opts ^. #output of
    Just path -> writeFileUtf8 path txt
    Nothing   -> hPutBuilder stdout (getUtf8Builder $ display txt)

run :: Format -> Config -> IO (Either ServiceException Text)
run MDFormat conf   = runServiceM conf $ toMarkdown =<< genInfo whoami
run JSONFormat conf = runServiceM conf $ toJsonText =<< genInfo whoami

versionOpt :: OptDescr' Bool
versionOpt = optFlag [] ["version"] "Show version"

showVersion :: Version -> String
showVersion v = unwords
  [ "Version"
  , Version.showVersion v ++ ","
  , "Git revision"
  , $(gitHash)
  , "(" ++ $(gitCommitCount) ++ " commits)"
  ]
