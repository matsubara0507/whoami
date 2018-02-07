{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Whoami.Service.AnyLib where

import           Control.Applicative            ((<|>))
import           Control.Lens                   ((%~), (&), (^.))
import           Data.Extensible
import           Data.Maybe                     (fromMaybe)
import           Whoami.Service.Data.Class      (Service (..))
import           Whoami.Service.Data.Config     (LibConfig)
import           Whoami.Service.Data.Info       (Library (..), ServiceType)
import           Whoami.Service.Internal.Fetch  (fetchHtml)
import           Whoami.Service.Internal.Scrape (scrapeDesc)

data AnyLib = AnyLib LibConfig

instance Service AnyLib where
  fetch (AnyLib conf) = fetchHtml $ conf ^. #url
  fill (AnyLib conf) html =
    pure . AnyLib $ conf & #description %~ (<|> scrapeDesc html)
  uniform (AnyLib conf) =
    pure (shrink $ #description @= desc <: #type @= libt <: conf)
    where
      desc = fromMaybe "" $ conf ^. #description
      libt :: ServiceType
      libt = embed $ #lib @= (Library $ shrink conf)
