module Main where

import           RIO
import qualified Test.Whoami.Output
import qualified Test.Whoami.Service

import           Test.Tasty

main :: IO ()
main = defaultMain =<< testGroup "whoami package" <$> sequence
  [ Test.Whoami.Service.tests
  , Test.Whoami.Output.tests
  ]
