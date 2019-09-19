module Test.Whoami.Service where

import           RIO

import           Test.Tasty
import qualified Test.Whoami.Service.AnyApp
import qualified Test.Whoami.Service.AnyLib
import qualified Test.Whoami.Service.AnyPost
import qualified Test.Whoami.Service.AnySite

tests :: IO TestTree
tests = testGroup "Whoami.Service" <$> sequence
  [ testGroup "AnyApp.anyAppToInfo" <$>
      Test.Whoami.Service.AnyApp.test_anyAppToInfo
  , testGroup "AnyLib.anyLibToInfo" <$>
      Test.Whoami.Service.AnyLib.test_anyLibToInfo
  , testGroup "AnyPost.anyPostToInfo" <$>
      Test.Whoami.Service.AnyPost.test_anyPostToInfo
  , testGroup "AnySite.anySiteToInfo" <$>
      Test.Whoami.Service.AnySite.test_anySiteToInfo
  ]
