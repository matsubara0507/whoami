module Test.Whoami.Service.AnyLib where

import           RIO
import           RIO.List.Partial ((!!))

import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

{-# ANN test_anyLibToInfo ("HLint: ignore Use head" :: String) #-}
test_anyLibToInfo :: IO [TestTree]
test_anyLibToInfo = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example lib0 to uniformed info" .
        (@?= Right lib0) <$> runServiceM conf (toInfo . AnyLib $ (conf ^. #library) !! 0)
    , testCase "example lib1 to uniformed info" .
        (@?= Right lib1) <$> runServiceM conf (toInfo . AnyLib $ (conf ^. #library) !! 1)
    ]
