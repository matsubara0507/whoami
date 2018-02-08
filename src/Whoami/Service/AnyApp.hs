{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Whoami.Service.AnyApp where

import           Control.Applicative            ((<|>))
import           Control.Lens                   ((%~), (&), (^.))
import           Data.Extensible
import           Data.Maybe                     (fromMaybe)
import           Whoami.Service.Data.Class      (Uniform (..))
import           Whoami.Service.Data.Config     (AppConfig)
import           Whoami.Service.Data.Info       (Application (..), ServiceType)
import           Whoami.Service.Internal.Fetch  (fetchHtml)
import           Whoami.Service.Internal.Scrape (scrapeDesc)

newtype AnyApp = AnyApp AppConfig

instance Uniform AnyApp where
  fetch (AnyApp conf) = fetchHtml $ conf ^. #url
  fill (AnyApp conf) html =
    pure . AnyApp $ conf & #description %~ (<|> scrapeDesc html)
  uniform (AnyApp conf) =
    pure (shrink $ #description @= desc <: #type @= appt <: conf)
    where
      desc = fromMaybe "" $ conf ^. #description
      appt :: ServiceType
      appt = embed $ #app @= Application
