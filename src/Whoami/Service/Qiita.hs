{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Whoami.Service.Qiita where

import           Control.Lens                  (view, (^.))
import           Control.Monad                 ((<=<))
import           Control.Monad.Error.Class     (throwError)
import           Control.Monad.Reader          (reader)
import           Data.Default                  (def)
import           Data.Extensible
import qualified Data.Map                      as Map
import           Data.Maybe                    (fromMaybe)
import           Data.Text                     (Text)
import qualified Data.Text                     as T
import           Network.HTTP.Req
import           Whoami.Service.AnyPost        (AnyPost (..))
import           Whoami.Service.Data.Class     (Service (..),
                                                ServiceException (..), ServiceM,
                                                Uniform (..))
import           Whoami.Service.Internal.Fetch (runReq', throwFetchError)

type QiitaPost = Record
  '[ "title" >: Text
   , "updated_at" >: Text
   , "url" >: Text
   ]

data Qiita

qiita :: Proxy Qiita
qiita = Proxy

instance Service Qiita where
  genInfo _ = do
    conf <- reader (view #qiita)
    if fromMaybe False (conf ^. #posts) then
      mapM (uniform <=< flip fill "" . toPost) =<< fetchQiitaPosts
    else
      return []

fetchQiitaPosts :: ServiceM [QiitaPost]
fetchQiitaPosts = do
  account <- Map.lookup "qiita" <$> reader (view #account)
  case account of
    Just name -> fetchQiitaPosts' name
    Nothing   -> throwError $ ServiceException "qiita account is not defined"

fetchQiitaPosts' :: Text -> ServiceM [QiitaPost]
fetchQiitaPosts' name = do
  num <- fromMaybe 100 <$> reader (view #count . view #qiita)
  let
    url = https "qiita.com" /: "api" /: "v2" /: "users" /: name /: "items"
    params = "per_page" =: num
  result <- runReq' def $ req GET url NoReqBody jsonResponse params
  case result of
    Left err   -> throwFetchError (Left err)
    Right resp -> pure $ responseBody resp

toPost :: QiitaPost -> AnyPost
toPost post = AnyPost
   $ #title @= Just (post ^. #title)
  <: #url   @= post ^. #url
  <: #date  @= Just (T.take (T.length "yyyy-mm-dd") $ post ^. #updated_at)
  <: nil
