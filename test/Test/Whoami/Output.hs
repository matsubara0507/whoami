module Test.Whoami.Output where

import           RIO

import           Test.Tasty
import qualified Test.Whoami.Output.Json
import qualified Test.Whoami.Output.Markdown

tests :: IO TestTree
tests = testGroup "Whoami.Output" <$> sequence
  [ testGroup "Json.toJsonText" <$>
      Test.Whoami.Output.Json.test_toJsonText
  , testGroup "Markdown.toMarkdown" <$>
      Test.Whoami.Output.Markdown.test_toMarkdown
  ]
