{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.AnyPost where

import           Control.Lens                    ((^.))
import           Control.Monad                   (sequence)
import           Data.Extensible
import           Data.Extensible.Instances.Aeson ()
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

post0 :: Info
post0
    = #name @= "Haskell Advent Calendar 2017 まとめ - Haskell-jp"
   <: #url @= "http://haskell.jp/blog/posts/2017/advent-calendar-2017.html"
   <: #description @= "posted on 2017-12-31"
   <: #type @= embedAssoc (#post @= Post (#date @= "2017-12-31" <: nil))
   <: nil

post1 :: Info
post1
    = #name @= "Slack から特定のアカウントでツイートする Bot を作った | 群馬大学電子計算機研究会 IGGG"
   <: #url @= "http://iggg.github.io/2017/06/01/make-tweet-slack-bot"
   <: #description @= "posted on 2017-06-01"
   <: #type @= embedAssoc (#post @= Post (#date @= "2017-06-01" <: nil))
   <: nil

{-# ANN test_anyPostToInfo ("HLint: ignore Use head" :: String) #-}
test_anyPostToInfo :: IO [TestTree]
test_anyPostToInfo = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example post0 to uniformed info" .
        (@?= Right post0) <$> runServiceM conf (toInfo . AnyPost $ (conf ^. #post ^. #posts) !! 0)
    , testCase "example post1 to uniformed info" .
        (@?= Right post1) <$> runServiceM conf (toInfo . AnyPost $ (conf ^. #post ^. #posts) !! 1)
    ]
