{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Whoami.Output.Json
  ( toJsonText
  , Infos
  , Info'
  ) where

import           Control.Lens             ((^.))
import           Control.Monad.Reader     (ask)
import           Data.Aeson.Encode.Pretty (encodePretty)
import           Data.Extensible
import           Data.List                (sortBy)
import           Data.Map                 (Map)
import           Data.Maybe               (fromMaybe)
import           Data.Text                (Text)
import           Data.Text.Conversions    (UTF8 (..), decodeConvertText)
import           Whoami.Service

type Infos = Record
  '[ "name"    >: Text
   , "account" >: Map Text Url
   , "site"    >: [Info']
   , "post"    >: [Info']
   , "library" >: [Info']
   , "app"     >: [Info']
   ]

type Info' = Record
  '[ "name" >: Text
   , "url" >: Url
   , "description" >: Text
   ]

toJsonText :: [Info] -> ServiceM Text
toJsonText infos = do
  conf <- ask
  let
    posts' = sortBy (\a b -> compare (getDate b) (getDate a)) $ filter isPost infos
    num = fromMaybe (length posts) (conf ^. #post ^. #latest)
  pure . toText
     $ #name    @= conf ^. #name
    <: #account @= conf ^. #account
    <: #site    @= shrink <$> filter isSite infos
    <: #post    @= shrink <$> take num posts'
    <: #library @= shrink <$> filter isLib  infos
    <: #app     @= shrink <$> filter isApp  infos
    <: nil

toText :: Infos -> Text
toText = fromMaybe "" . decodeConvertText . UTF8 .  encodePretty
