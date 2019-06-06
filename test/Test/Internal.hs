module Test.Internal where

import           RIO

import           Data.Extensible
import           Whoami

exampleConfigFile :: FilePath
exampleConfigFile = "example/whoami.yaml"

exampleInfos :: [Info]
exampleInfos = [ site0, post0, post1, app0, app1, lib0, lib1 ]

site0 :: Info
site0
    = #name @= "ひげメモ"
   <: #url @= "https://matsubara0507.github.io"
   <: #description @= "メモ書きブログ"
   <: #type @= embedAssoc (#site @= Site)
   <: nil

post0 :: Info
post0
    = #name @= "Haskell Advent Calendar 2017 まとめ - Haskell-jp"
   <: #url @= "https://haskell.jp/blog/posts/2017/advent-calendar-2017.html"
   <: #description @= "posted on 2017-12-31"
   <: #type @= embedAssoc (#post @= Post (#date @= "2017-12-31" <: nil))
   <: nil

post1 :: Info
post1
    = #name @= "Slack から特定のアカウントでツイートする Bot を作った | 群馬大学電子計算機研究会 IGGG"
   <: #url @= "https://iggg.github.io/2017/06/01/make-tweet-slack-bot"
   <: #description @= "posted on 2017-06-01"
   <: #type @= embedAssoc (#post @= Post (#date @= "2017-06-01" <: nil))
   <: nil

app0 :: Info
app0
    = #name @= "AnaQRam"
   <: #url @= "https://github.com/matsubara0507/AnaQRam"
   <: #description @= "QRコードを利用したアナグラム(並び替えパズル)"
   <: #type @= embedAssoc (#app @= Application)
   <: nil

app1 :: Info
app1
    = #name @= "timeout-sesstype-cli"
   <: #url @= "https://github.com/matsubara0507/timeout-sesstype.hs"
   <: #description @= "修論で定義した疑似言語のCLI"
   <: #type @= embedAssoc (#app @= Application)
   <: nil

lib0 :: Info
lib0
    = #name @= "chatwork"
   <: #url @= "https://hackage.haskell.org/package/chatwork"
   <: #description @= "The ChatWork API in Haskell"
   <: #type @= embedAssoc (#lib @= Library (#language @= "haskell" <: nil))
   <: nil

lib1 :: Info
lib1
    = #name @= "thank_you_stars"
   <: #url @= "https://hex.pm/packages/thank_you_stars"
   <: #description @= "A tool for starring GitHub repositories."
   <: #type @= embedAssoc (#lib @= Library (#language @= "elixir" <: nil))
   <: nil
