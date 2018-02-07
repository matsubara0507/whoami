{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Test.Whoami.Service.AnyApp where

import           Control.Lens                    ((^.))
import           Control.Monad                   (sequence)
import           Data.Extensible
import           Data.Extensible.Instances.Aeson ()
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Whoami

app0 :: Info
app0
    = #name @= "AnaQRam"
   <: #url @= "http://github.com/matsubara0507/AnaQRam"
   <: #description @= "QRコードを利用したアナグラム(並び替えパズル)"
   <: #type @= embedAssoc (#app @= Application)
   <: nil

app1 :: Info
app1
    = #name @= "timeout-sesstype-cli"
   <: #url @= "http://github.com/matsubara0507/timeout-sesstype.hs"
   <: #description @= "修論で定義した疑似言語のCLI"
   <: #type @= embedAssoc (#app @= Application)
   <: nil

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
