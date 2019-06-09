module Whoami.Service.Medium where

import           RIO
import qualified RIO.Map                       as Map
import qualified RIO.Text                      as Text
import           RIO.Time

import           Data.Extensible
import           Network.HTTP.Req
import qualified Text.Feed.Import              as Feed
import           Text.Feed.Types               (Feed (..))
import qualified Text.RSS.Syntax               as Feed
import           Whoami.Service.AnyPost        (AnyPost (..))
import           Whoami.Service.Data.Class     (Service (..),
                                                ServiceException (..), ServiceM,
                                                Uniform (..))
import           Whoami.Service.Internal.Fetch (runReq', throwFetchError)

type MediumPost = Record
  '[ "title"   >: Maybe Text
   , "pubDate" >: Maybe Text
   , "link"    >: Maybe Text
   ]

data Medium

medium :: Proxy Medium
medium = Proxy

instance Service Medium where
  genInfo _ = do
    conf <- asks (view #medium . view #config)
    if fromMaybe False (conf ^. #posts) then do
      let maxPostCnt = fromMaybe 10 $ conf ^. #count
      posts <- map toPost <$> fetchMediumPosts
      mapM (uniform <=< flip fill "") $ take maxPostCnt (catMaybes posts)
    else
      return []

fetchMediumPosts :: ServiceM [MediumPost]
fetchMediumPosts = do
  account <- Map.lookup "medium" <$> asks (view #account . view #config)
  case account of
    Just name -> fetchMediumPosts' name
    Nothing   -> throwM $ ServiceException "medium account is not defined"

fetchMediumPosts' :: Text -> ServiceM [MediumPost]
fetchMediumPosts' name = do
  result <- runReq' defaultHttpConfig $ req GET url NoReqBody lbsResponse mempty
  case result of
    Left err   -> throwFetchError (Left err)
    Right resp -> pure $ parseFeed (responseBody resp)
  where
    url = https "medium.com" /: "feed" /: ("@" <> name)

parseFeed :: LByteString -> [MediumPost]
parseFeed bs = case Feed.parseFeedSource bs of
  Just (RSSFeed feed) -> toMediumPost <$> Feed.rssItems (Feed.rssChannel feed)
  _                   -> []

toMediumPost :: Feed.RSSItem -> MediumPost
toMediumPost post
    = #title   @= Feed.rssItemTitle post
   <: #pubDate @= Feed.rssItemPubDate post
   <: #link    @= Feed.rssItemLink post
   <: nil

toPost :: MediumPost -> Maybe AnyPost
toPost post = do
  link' <- post ^. #link
  pure . AnyPost
      $ #title @= post ^. #title
     <: #url   @= Text.takeWhile (/= '?') link'
     <: #date  @= (formatDate =<< post ^. #pubDate)
     <: nil

formatDate :: Text -> Maybe Text
formatDate date =
  fromString . formatTime defaultTimeLocale (iso8601DateFormat Nothing) <$> day
  where
    day :: Maybe Day
    day = parseTimeM True defaultTimeLocale rfc822DateFormat (Text.unpack date)
