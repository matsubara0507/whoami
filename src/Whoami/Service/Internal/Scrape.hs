{-# LANGUAGE OverloadedStrings #-}

module Whoami.Service.Internal.Scrape where

import           Data.Text                 (Text)
import qualified Data.Text                 as T
import           Text.HTML.Scalpel.Core
import           Whoami.Service.Data.Class (Data)
import           Whoami.Service.Data.Info  (Date)

scrapeTitle :: Data -> Maybe Text
scrapeTitle = flip scrapeStringLike titleScraper

scrapeDate :: Data -> Maybe Date
scrapeDate = flip scrapeStringLike dateScraper

titleScraper :: Scraper Data Text
titleScraper = text "title"

dateScraper :: Scraper Data Text
dateScraper = T.take (T.length "yyyy-mm-dd") <$> attr "datetime" "time"
