module Test.Whoami.Service.AnyApp where

import           RIO
import           RIO.List.Partial ((!!))

import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

{-# ANN test_anyAppToInfo ("HLint: ignore Use head" :: String) #-}
test_anyAppToInfo :: IO [TestTree]
test_anyAppToInfo = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example app0 to uniformed info" .
        (@?= Right app0) <$> runServiceM conf (toInfo . AnyApp $ (conf ^. #app) !! 0)
    , testCase "example app1 to uniformed info" .
        (@?= Right app1) <$> runServiceM conf (toInfo . AnyApp $ (conf ^. #app) !! 1)
    ]
