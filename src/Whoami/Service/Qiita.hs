module Whoami.Service.Qiita where

import           RIO
import qualified RIO.Map                       as Map
import qualified RIO.Text                      as Text

import           Data.Extensible
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
    conf <- asks (view #qiita . view #config)
    if fromMaybe False (conf ^. #posts) then
      mapM (uniform <=< flip fill "" . toPost) =<< fetchQiitaPosts
    else
      return []

fetchQiitaPosts :: ServiceM [QiitaPost]
fetchQiitaPosts = do
  account <- Map.lookup "qiita" <$> asks (view #account . view #config)
  case account of
    Just name -> fetchQiitaPosts' name
    Nothing   -> throwM $ ServiceException "qiita account is not defined"

fetchQiitaPosts' :: Text -> ServiceM [QiitaPost]
fetchQiitaPosts' name = do
  num <- fromMaybe 10 <$> asks (view #count . view #qiita . view #config)
  let url = https "qiita.com" /: "api" /: "v2" /: "users" /: name /: "items"
      params = "per_page" =: num
  result <- runReq' defaultHttpConfig $ req GET url NoReqBody jsonResponse params
  case result of
    Left err   -> throwFetchError (Left err)
    Right resp -> pure $ responseBody resp

toPost :: QiitaPost -> AnyPost
toPost post = AnyPost
   $ #title @= Just (post ^. #title)
  <: #url   @= post ^. #url
  <: #date  @= Just (Text.take (Text.length "yyyy-mm-dd") $ post ^. #updated_at)
  <: nil
