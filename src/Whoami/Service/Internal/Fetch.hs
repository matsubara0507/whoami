{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Whoami.Service.Internal.Fetch where

import           Control.Monad                 ((<=<))
import           Control.Monad.Catch           (try)
import           Control.Monad.Error.Class     (throwError)
import           Control.Monad.IO.Class        (MonadIO (..))
import           Control.Monad.Logger          (logInfo)
import           Control.Monad.Reader.Class    (reader)
import           Data.Default                  (def)
import           Data.Maybe                    (fromMaybe)
import           Data.Monoid                   ((<>))
import           Data.Proxy                    (Proxy)
import           Data.Text                     (Text, pack)
import           Data.Text.Conversions         (UTF8 (..), decodeConvertText)
import           Data.Text.Encoding            (encodeUtf8)
import           Network.HTTP.Req
import           Whoami.Service.Data.Class     (Data, ServiceException (..),
                                                ServiceM)
import           Whoami.Service.Data.Config    (Config)
import qualified Whoami.Service.Data.Info      as Whoami
import           Whoami.Service.Internal.Utils (sleep)

pingWith :: (Config -> Whoami.Url) -> ServiceM Data
pingWith = ping <=< reader

ping :: Whoami.Url -> ServiceM Data
ping url = do
  result <- get' url ignoreResponse
  case result of
    Left err -> throwFetchError (Left err)
    Right resp -> case responseStatusCode resp of
      200  -> pure ""
      code -> throwFetchError (Right . pack $ "bad status code: " <> show code)

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
      runReq' def (req GET url' NoReqBody proxy opts) <* sleep' 1
    Nothing ->
      case parseUrlHttps (encodeUtf8 url) of
        Just (url', opts) ->
          runReq' def (req GET url' NoReqBody proxy opts) <* sleep' 1
        Nothing ->
          throwFetchError (Right $ "cannot parse url: " <> url)
  where
    sleep' n = $(logInfo) ("fethed: " `mappend` url) *> sleep n


runReq' :: (MonadIO m) => HttpConfig -> Req a -> m (Either HttpException a)
runReq' conf = liftIO . try . runReq conf

throwFetchError :: Either HttpException Text -> ServiceM a
throwFetchError = throwError . FetchException
