{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.AnyLib where

import           Control.Lens                    ((^.))
import           Control.Monad                   (sequence)
import           Data.Extensible
import           Data.Extensible.Instances.Aeson ()
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

lib0 :: Info
lib0
    = #name @= "chatwork"
   <: #url @= "http://hackage.haskell.org/package/chatwork"
   <: #description @= "The ChatWork API in Haskell"
   <: #type @= embedAssoc (#lib @= Library (#language @= "haskell" <: nil))
   <: nil

lib1 :: Info
lib1
    = #name @= "thank_you_stars"
   <: #url @= "http://hex.pm/packages/thank_you_stars"
   <: #description @= "A tool for starring GitHub repositories."
   <: #type @= embedAssoc (#lib @= Library (#language @= "elixir" <: nil))
   <: nil

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
