{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Whoami.Service.AnyPost where

import           Control.Applicative             ((<|>))
import           Control.Lens                    ((%~), (&), (^.))
import           Data.Extensible
import           Whoami.Service.Data.Class       (Service (..))
import           Whoami.Service.Data.Config      (PostConfig)
import           Whoami.Service.Data.Info        (Post (..))
import           Whoami.Service.Internal.Fetch   (fetchHtml)
import           Whoami.Service.Internal.Scrape  (scrapeDate, scrapeTitle)
import           Whoami.Service.Internal.Uniform (throwUniformError)
import           Whoami.Service.Internal.Utils   (embedM)

data AnyPost = AnyPost PostConfig

instance Service AnyPost where
  fetch (AnyPost conf) = fetchHtml $ conf ^. #url
  fill (AnyPost conf) html = pure . AnyPost $
    conf & #title %~ (<|> scrapeTitle html) & #date %~ (<|> scrapeDate html)
  uniform (AnyPost conf) = hsequence
      $ #name <@=> maybe (throwUniformError "no #title") pure (conf ^. #title)
     <: #url <@=> pure (conf ^. #url)
     <: #description <@=> mappend "posted on " <$> date
     <: #type <@=> embedM (#post <@=> Post <$> hsequence (#date <@=> date <: nil))
     <: nil
    where
      date = maybe (throwUniformError "no #date") pure $ conf ^. #date
