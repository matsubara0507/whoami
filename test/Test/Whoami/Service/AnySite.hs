{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.AnySite where

import           Control.Lens                    ((^.))
import           Control.Monad                   (sequence)
import           Data.Extensible.Instances.Aeson ()
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

{-# ANN test_anySiteToInfo ("HLint: ignore Use head" :: String) #-}
test_anySiteToInfo :: IO [TestTree]
test_anySiteToInfo = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example site0 to uniformed info" .
        (@?= Right site0) <$> runServiceM conf (toInfo . AnySite $ (conf ^. #site) !! 0)
    ]
