{-# LANGUAGE OverloadedStrings #-}

module Whoami.Service.Internal.Scrape where

import           Control.Applicative       ((<|>))
import           Data.Text                 (Text)
import qualified Data.Text                 as T
import           Text.HTML.Scalpel.Core
import           Whoami.Service.Data.Class (Data)
import           Whoami.Service.Data.Info  (Date)

scrapeTitle :: Data -> Maybe Text
scrapeTitle = flip scrapeStringLike titleScraper

scrapeDate :: Data -> Maybe Date
scrapeDate = flip scrapeStringLike dateScraper

scrapeDesc :: Data -> Maybe Text
scrapeDesc = flip scrapeStringLike descScraper

titleScraper :: Scraper Data Text
titleScraper = text "title"

dateScraper :: Scraper Data Text
dateScraper = T.take (T.length "yyyy-mm-dd") <$> attr "datetime" "time"

descScraper :: Scraper Data Text
descScraper =
      attr "content" ("meta" @: [ "name" @= "description" ])
  <|> attr "content" ("meta" @: [ "property" @= "og:description" ])
