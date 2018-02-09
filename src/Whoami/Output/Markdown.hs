{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Whoami.Output.Markdown where

import           Control.Lens         (view, (^.))
import           Control.Monad.Reader (reader)
import           Data.List            (sortBy)
import qualified Data.Map             as Map
import           Data.Maybe           (catMaybes, fromMaybe)
import           Data.Text            (Text)
import qualified Data.Text            as T
import           Whoami.Service

type Markdown = Text

toMarkdown :: [Info] -> ServiceM Markdown
toMarkdown infos = T.unlines . concat <$> sequence
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
  name <- reader (view #name)
  pure $ [ "# " `mappend` name ]

toMarkdownAccount :: ServiceM [Markdown]
toMarkdownAccount = do
  account <- reader (view #account)
  pure $ catMaybes
    [ toLink "github" "https://github.com/" <$> Map.lookup "github" account
    , toLink "qiita"  "https://qiita.com/"  <$> Map.lookup "qiita"  account
    ]
  where
    toLink base service name = mconcat [ "- [", service, "](", base, name, ")" ]

toMarkdownSites :: [Info] -> ServiceM [Markdown]
toMarkdownSites infos =
  pure $ concat (["## My Sites"] : fmap toMarkdownInfo (filter isSite infos))

toMarkdownPosts :: [Info] -> ServiceM [Markdown]
toMarkdownPosts infos = do
  let
    posts' = sortBy (\a b -> compare (getDate b) (getDate a)) $ filter isPost infos
  num <- fromMaybe (length posts) <$> reader (view #latest . view #post)
  pure $ concat (["## My Posts"] : fmap toMarkdownInfo (take num posts'))

toMarkdownApps :: [Info] -> ServiceM [Markdown]
toMarkdownApps infos =
  pure $ concat (["## Applications"] : fmap toMarkdownInfo (filter isApp infos))

toMarkdownLibs :: [Info] -> ServiceM [Markdown]
toMarkdownLibs infos =
  pure $ concat (["## Libraries"] : fmap toMarkdownInfo (filter isLib infos))

toMarkdownInfo :: Info -> [Markdown]
toMarkdownInfo info =
  [ mconcat [ "- [", info ^. #name, "](", info ^. #url, ")"]
  , mconcat [ "    - ", info ^. #description ]
  ]

newline :: Monad m => m [Markdown]
newline = pure [""]
