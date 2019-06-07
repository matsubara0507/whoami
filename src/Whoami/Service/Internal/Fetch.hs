module Whoami.Service.Internal.Fetch where

import           RIO                           hiding (Data)

import           Data.Text.Conversions         (UTF8 (..), decodeConvertText)
import qualified Mix.Plugin.Config             as Mix
import           Network.HTTP.Req
import           Whoami.Service.Data.Class     (Data, ServiceException (..),
                                                ServiceM)
import           Whoami.Service.Data.Config    (Config)
import qualified Whoami.Service.Data.Info      as Whoami
import           Whoami.Service.Internal.Utils (sleep)

pingWith :: (Config -> Whoami.Url) -> ServiceM Data
pingWith f = (ping . f) =<< Mix.askConfig

ping :: Whoami.Url -> ServiceM Data
ping url = do
  result <- get' url ignoreResponse
  case result of
    Left err -> throwFetchError (Left err)
    Right resp -> case responseStatusCode resp of
      200  -> pure ""
      code -> throwFetchError (Right . fromString $ "bad status code: " <> show code)

fetchHtml :: Whoami.Url -> ServiceM Data
fetchHtml url = do
  result <- get' url bsResponse
  case result of
    Left err   -> throwFetchError (Left err)
    Right resp ->
      pure . fromMaybe "" $ decodeConvertText (UTF8 $ responseBody resp)

get' :: HttpResponse resp =>
  Whoami.Url -> Proxy resp -> ServiceM (Either HttpException resp)
get' url proxy =
  case parseUrlHttp (encodeUtf8 url) of
    Just (url', opts) ->
      runReq' defaultHttpConfig (req GET url' NoReqBody proxy opts) <* sleep' 1
    Nothing ->
      case parseUrlHttps (encodeUtf8 url) of
        Just (url', opts) ->
          runReq' defaultHttpConfig (req GET url' NoReqBody proxy opts) <* sleep' 1
        Nothing ->
          throwFetchError (Right $ "cannot parse url: " <> url)
  where
    sleep' n = logInfo (display $ "fethed: " <> url) *> sleep n


runReq' :: (MonadIO m) => HttpConfig -> Req a -> m (Either HttpException a)
runReq' conf = liftIO . try . runReq conf

throwFetchError :: Either HttpException Text -> ServiceM a
throwFetchError = throwIO . FetchException
