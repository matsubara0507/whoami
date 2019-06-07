module Test.Whoami.Output.Json where

import           RIO

import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Text.Heredoc
import           Whoami.Output.Json        (toJsonText)
import           Whoami.Service.Data.Class (runServiceM)

exampleJson :: Text
exampleJson = fromString
  [str|{
      |    "library": [
      |        {
      |            "url": "https://hackage.haskell.org/package/chatwork",
      |            "name": "chatwork",
      |            "description": "The ChatWork API in Haskell"
      |        },
      |        {
      |            "url": "https://hex.pm/packages/thank_you_stars",
      |            "name": "thank_you_stars",
      |            "description": "A tool for starring GitHub repositories."
      |        }
      |    ],
      |    "post": [
      |        {
      |            "url": "https://haskell.jp/blog/posts/2017/advent-calendar-2017.html",
      |            "name": "Haskell Advent Calendar 2017 まとめ - Haskell-jp",
      |            "description": "posted on 2017-12-31"
      |        },
      |        {
      |            "url": "https://iggg.github.io/2017/06/01/make-tweet-slack-bot",
      |            "name": "Slack から特定のアカウントでツイートする Bot を作った | 群馬大学電子計算機研究会 IGGG",
      |            "description": "posted on 2017-06-01"
      |        }
      |    ],
      |    "app": [
      |        {
      |            "url": "https://github.com/matsubara0507/AnaQRam",
      |            "name": "AnaQRam",
      |            "description": "QRコードを利用したアナグラム(並び替えパズル)"
      |        },
      |        {
      |            "url": "https://github.com/matsubara0507/timeout-sesstype.hs",
      |            "name": "timeout-sesstype-cli",
      |            "description": "修論で定義した疑似言語のCLI"
      |        }
      |    ],
      |    "account": {
      |        "qiita": "matsubara0507",
      |        "github": "matsubara0507"
      |    },
      |    "name": "MATSUBARA Nobutada",
      |    "site": [
      |        {
      |            "url": "https://matsubara0507.github.io",
      |            "name": "ひげメモ",
      |            "description": "メモ書きブログ"
      |        }
      |    ]
      |}|]

test_toJsonText :: IO [TestTree]
test_toJsonText = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example to convert json" .
        (@?= Right exampleJson) <$> runServiceM conf (toJsonText exampleInfos)
    ]
