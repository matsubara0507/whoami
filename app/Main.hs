module Main where

import           Paths_whoami           (version)
import           RIO
import qualified RIO.ByteString         as B

import           Data.Extensible
import           Data.Extensible.GetOpt
import           Data.Yaml              (ParseException, decodeEither',
                                         decodeFileEither)
import           GetOpt                 (withGetOpt')
import qualified Version
import           Whoami

main :: IO ()
main = withGetOpt' "[options] [input-file]" opts $ \r args usage -> if
  | r ^. #help    -> hPutBuilder stdout (fromString usage)
  | r ^. #version -> hPutBuilder stdout (Version.build version <> "\n")
  | otherwise     -> run (#input @= toInput args <: r)
  where
    run opts' = runCmd opts' >>= \case
      Left err  -> hPutBuilder stderr (fromString $ show err <> "\n")
      Right txt -> writeOutput opts' txt

    runCmd opts' = readInput opts' >>= \case
      Left err   -> pure $ Left (ReadConfigException $ tshow err)
      Right conf -> runServiceM (opts' ^. #verbose) conf (actBy $ opts' ^. #write)

    opts = #output  @= outputOpt
        <: #write   @= writeFormatOpt
        <: #verbose @= verboseOpt
        <: #version @= versionOpt
        <: #help    @= helpOpt
        <: nil

    actBy format = case format of
      MDFormat   -> toMarkdown =<< genInfo whoami
      JSONFormat -> toJsonText =<< genInfo whoami

type Options = Record
  '[ "input"   >: Maybe FilePath
   , "output"  >: Maybe FilePath
   , "write"   >: Format
   , "verbose" >: Bool
   , "version" >: Bool
   , "help"    >: Bool
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

verboseOpt :: OptDescr' Bool
verboseOpt = optFlag ['v'] ["verbose"] "Enable verbose mode: verbosity level \"debug\""

versionOpt :: OptDescr' Bool
versionOpt = optFlag [] ["version"] "Show version"

helpOpt :: OptDescr' Bool
helpOpt = optFlag ['h'] ["help"] "Show this help text"
