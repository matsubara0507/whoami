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
      |    "account": {
      |        "github": "matsubara0507",
      |        "qiita": "matsubara0507"
      |    },
      |    "app": [
      |        {
      |            "description": "QRコードを利用したアナグラム(並び替えパズル)",
      |            "name": "AnaQRam",
      |            "url": "https://github.com/matsubara0507/AnaQRam"
      |        },
      |        {
      |            "description": "修論で定義した疑似言語のCLI",
      |            "name": "timeout-sesstype-cli",
      |            "url": "https://github.com/matsubara0507/timeout-sesstype.hs"
      |        }
      |    ],
      |    "library": [
      |        {
      |            "description": "The ChatWork API in Haskell",
      |            "name": "chatwork",
      |            "url": "https://hackage.haskell.org/package/chatwork"
      |        },
      |        {
      |            "description": "A tool for starring GitHub repositories.",
      |            "name": "thank_you_stars",
      |            "url": "https://hex.pm/packages/thank_you_stars"
      |        }
      |    ],
      |    "name": "MATSUBARA Nobutada",
      |    "post": [
      |        {
      |            "description": "posted on 2017-12-31",
      |            "name": "Haskell Advent Calendar 2017 まとめ - Haskell-jp",
      |            "url": "https://haskell.jp/blog/posts/2017/advent-calendar-2017.html"
      |        },
      |        {
      |            "description": "posted on 2017-06-01",
      |            "name": "Slack から特定のアカウントでツイートする Bot を作った | 群馬大学電子計算機研究会 IGGG",
      |            "url": "https://iggg.github.io/2017/06/01/make-tweet-slack-bot"
      |        }
      |    ],
      |    "site": [
      |        {
      |            "description": "メモ書きブログ",
      |            "name": "ひげメモ",
      |            "url": "https://matsubara0507.github.io"
      |        }
      |    ]
      |}|]

test_toJsonText :: IO [TestTree]
test_toJsonText = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example to convert json" .
        (@?= Right exampleJson) <$> runServiceM False conf (toJsonText exampleInfos)
    ]
