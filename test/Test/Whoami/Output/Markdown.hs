{-# LANGUAGE QuasiQuotes #-}

module Test.Whoami.Output.Markdown where

import           Data.Text                 (pack)
import           Data.Yaml
import           Test.Internal
import           Test.Tasty
import           Test.Tasty.HUnit
import           Text.Heredoc
import           Whoami.Output.Markdown    (Markdown, toMarkdown)
import           Whoami.Service.Data.Class (runServiceM)

exampleMD :: Markdown
exampleMD = pack $
  [str|# MATSUBARA Nobutada
      |- [GitHub](https://github.com/matsubara0507)
      |- [Qiita](https://qiita.com/matsubara0507)
      |
      |## My Sites
      |- [ひげメモ](http://matsubara0507.github.io)
      |    - メモ書きブログ
      |
      |## My Posts
      |- [Haskell Advent Calendar 2017 まとめ - Haskell-jp](http://haskell.jp/blog/posts/2017/advent-calendar-2017.html)
      |    - posted on 2017-12-31
      |- [Slack から特定のアカウントでツイートする Bot を作った｜群馬大学電子計算機研究会 IGGG](http://iggg.github.io/2017/06/01/make-tweet-slack-bot)
      |    - posted on 2017-06-01
      |
      |## Applications
      |- [AnaQRam](http://github.com/matsubara0507/AnaQRam)
      |    - QRコードを利用したアナグラム(並び替えパズル)
      |- [timeout-sesstype-cli](http://github.com/matsubara0507/timeout-sesstype.hs)
      |    - 修論で定義した疑似言語のCLI
      |
      |## Libraries
      |- [chatwork](http://hackage.haskell.org/package/chatwork)
      |    - The ChatWork API in Haskell
      |- [thank_you_stars](http://hex.pm/packages/thank_you_stars)
      |    - A tool for starring GitHub repositories.
      |]

test_toMarkdown :: IO [TestTree]
test_toMarkdown = do
  (Right conf) <- decodeFileEither exampleConfigFile
  sequence
    [ testCase "example to convert markdown" .
        (@?= Right exampleMD) <$> runServiceM conf (toMarkdown exampleInfos)
    ]
