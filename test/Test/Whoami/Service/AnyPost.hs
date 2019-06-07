module Test.Whoami.Service.AnyPost where

import           RIO
import           RIO.List.Partial ((!!))

import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

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
