module Whoami.Output.Markdown where

import           RIO
import qualified RIO.List         as L
import qualified RIO.Map          as Map
import qualified RIO.Text         as Text
import qualified RIO.Text.Partial as Text

import           Whoami.Service

type Markdown = Text

toMarkdown :: [Info] -> ServiceM Markdown
toMarkdown infos = Text.unlines . concat <$> sequence
    [ toMarkdownName
    , toMarkdownAccount
    , newline
    , toMarkdownSites infos
    , newline
    , toMarkdownPosts infos
    , newline
    , toMarkdownApps infos
    , newline
    , toMarkdownLibs infos
    ]

toMarkdownName :: ServiceM [Markdown]
toMarkdownName = do
  name <- asks (view #name . view #config)
  pure [ "# " `mappend` name ]

toMarkdownAccount :: ServiceM [Markdown]
toMarkdownAccount = do
  account <- asks (view #account . view #config)
  pure $ catMaybes
    [ toLink "GitHub" "https://github.com/"  <$> Map.lookup "github" account
    , toLink "Qiita"  "https://qiita.com/"   <$> Map.lookup "qiita"  account
    , toLink "Medium" "https://medium.com/@" <$> Map.lookup "medium" account
    ]
  where
    toLink service base name = mconcat [ "- [", service, "](", base, name, ")" ]

toMarkdownSites :: [Info] -> ServiceM [Markdown]
toMarkdownSites infos =
  pure $ concat (["## My Sites"] : fmap toMarkdownInfo (filter isSite infos))

toMarkdownPosts :: [Info] -> ServiceM [Markdown]
toMarkdownPosts infos = do
  num <- fromMaybe (length posts) <$> asks (view #latest . view #post . view #config)
  pure $ concat (["## My Posts"] : fmap toMarkdownInfo (take num posts'))
  where
    posts' = L.sortBy (\a b -> compare (getDate b) (getDate a)) $ filter isPost infos

toMarkdownApps :: [Info] -> ServiceM [Markdown]
toMarkdownApps infos =
  pure $ concat (["## Applications"] : fmap toMarkdownInfo (filter isApp infos))

toMarkdownLibs :: [Info] -> ServiceM [Markdown]
toMarkdownLibs infos =
  pure $ concat (["## Libraries"] : fmap toMarkdownInfo (filter isLib infos))

toMarkdownInfo :: Info -> [Markdown]
toMarkdownInfo info =
  [ mconcat [ "- [", replaceVBar $ info ^. #name, "](", info ^. #url, ")"]
  , mconcat [ "    - ", info ^. #description ]
  ]

newline :: Monad m => m [Markdown]
newline = pure [""]

replaceVBar :: Text -> Text
replaceVBar = Text.replace " | " "｜"
