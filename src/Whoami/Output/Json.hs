{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

module Whoami.Output.Json
  ( toJsonText
  , Infos
  , Info'
  ) where

import           RIO
import qualified RIO.List                 as L

import           Data.Aeson.Encode.Pretty (encodePretty)
import           Data.Extensible
import           Data.Text.Conversions    (UTF8 (..), decodeConvertText)
import qualified Mix.Plugin.Config        as Mix
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
  conf <- Mix.askConfig
  let posts' = L.sortBy (\a b -> compare (getDate b) (getDate a)) $ filter isPost infos
      num = fromMaybe (length posts) (conf ^. #post ^. #latest)
  pure . toText
     $ #name    @= conf ^. #name
    <: #account @= conf ^. #account
    <: #site    @= fmap shrink (filter isSite infos)
    <: #post    @= fmap shrink (take num posts')
    <: #library @= fmap shrink (filter isLib  infos)
    <: #app     @= fmap shrink (filter isApp  infos)
    <: nil

toText :: Infos -> Text
toText = fromMaybe "" . decodeConvertText . UTF8 .  encodePretty
