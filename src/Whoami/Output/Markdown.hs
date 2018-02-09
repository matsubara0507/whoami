{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}

module Whoami.Output.Markdown where

import           Control.Lens         (view, (^.))
import           Control.Monad.Reader (reader)
import           Data.List            (sortBy)
import           Data.Maybe           (fromMaybe)
import           Data.Text            (Text)
import qualified Data.Text            as T
import           Whoami.Service

type Markdown = Text

toMarkdown :: [Info] -> ServiceM Markdown
toMarkdown infos = T.unlines . concat <$> sequence
  [ toMarkdownSites infos
  , newline
  , toMarkdownPosts infos
  , newline
  , toMarkdownApps infos
  , newline
  , toMarkdownLibs infos
  ]

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
