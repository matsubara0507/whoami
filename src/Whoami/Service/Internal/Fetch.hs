{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}

module Whoami.Service.Internal.Fetch where

import           Control.Monad              ((<=<))
import           Control.Monad.Catch        (try)
import           Control.Monad.Error.Class  (throwError)
import           Control.Monad.IO.Class     (MonadIO (..))
import           Control.Monad.Reader.Class (reader)
import           Data.Default               (def)
import           Data.Maybe                 (fromMaybe)
import           Data.Monoid                ((<>))
import           Data.Text                  (Text, pack)
import           Data.Text.Conversions      (UTF8 (..), decodeConvertText)
import           Data.Text.Encoding         (encodeUtf8)
import           Network.HTTP.Req
import           Whoami.Service.Data.Class  (Data, ServiceM,
                                             UniformException (..))
import           Whoami.Service.Data.Config (Config)
import qualified Whoami.Service.Data.Info   as Whoami

pingWith :: (Config -> Whoami.Url) -> ServiceM Data
pingWith = ping <=< reader

ping :: Whoami.Url -> ServiceM Data
ping url = do
  url' <- parseUrl url
  result <- runReq' def $ req GET url' NoReqBody ignoreResponse mempty
  case result of
    Left err -> throwFetchError (Left err)
    Right resp -> case responseStatusCode resp of
      200  -> pure ""
      code -> throwFetchError (Right . pack $ "bad status code: " <> show code)

fetchHtml :: Whoami.Url -> ServiceM Data
fetchHtml url = do
  url' <- parseUrl url
  result <- runReq' def $ req GET url' NoReqBody bsResponse mempty
  case result of
    Left err   -> throwFetchError (Left err)
    Right resp ->
      pure . fromMaybe "" $ decodeConvertText (UTF8 $ responseBody resp)


parseUrl :: Whoami.Url -> ServiceM (Url 'Http)
parseUrl url = maybe err (pure . fst) $ parseUrlHttp (encodeUtf8 url)
  where
    err = throwFetchError (Right $ "cannot parse url: " <> url)

runReq' :: (MonadIO m) => HttpConfig -> Req a -> m (Either HttpException a)
runReq' conf = liftIO . try . runReq conf

throwFetchError :: Either HttpException Text -> ServiceM a
throwFetchError = throwError . FetchException
