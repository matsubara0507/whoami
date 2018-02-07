{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.Internal.Scrape where

import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami
import           Whoami.Service.Internal.Scrape

titleTag :: Data
titleTag = "<title>Hoge</title>"

dateTag :: Data
dateTag =
  "<time datetime=\"2017-11-21T19:19:47+09:00\" itemprop=\"dateModified\">2017年11月21日</time>"

descTag1 :: Data
descTag1 =
  "<meta name=\"description\" content=\"A tool for starring GitHub repositories.\">"

descTag2 :: Data
descTag2 =
  "<meta content=\"A tool for starring GitHub repositories.\" property=\"og:description\">"

test_scraper :: [TestTree]
test_scraper =
  [ testCase "scrape page title" $
      scrapeTitle titleTag @?= Just "Hoge"
  , testCase "scrape date time" $
      scrapeDate dateTag @?= Just "2017-11-21"
  , testCase "scrape description using name attr" $
      scrapeDesc descTag1 @?= Just "A tool for starring GitHub repositories."
  , testCase "scrape description using property attr" $
      scrapeDesc descTag2 @?= Just "A tool for starring GitHub repositories."
  ]
