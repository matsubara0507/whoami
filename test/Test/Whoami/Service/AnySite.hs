{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.AnySite where

import           Control.Lens                    ((^.))
import           Control.Monad                   (sequence)
import           Data.Extensible
import           Data.Extensible.Instances.Aeson ()
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

site0 :: Info
site0
    = #name @= "ひげメモ"
   <: #url @= "http://matsubara0507.github.io"
   <: #description @= "メモ書きブログ"
   <: #type @= embedAssoc (#site @= Site)
   <: nil

test_anySiteToInfo :: IO [TestTree]
test_anySiteToInfo = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence $
    [ testCase "example site0 to uniformed info" <$>
        (@?= Right site0) <$> runServiceM conf (toInfo . AnySite $ (conf ^. #site) !! 0)
    ]
