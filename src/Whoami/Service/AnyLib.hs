{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Whoami.Service.AnyLib where

import           Control.Applicative            ((<|>))
import           Control.Lens                   (view, (%~), (&), (^.))
import           Control.Monad.Reader           (reader)
import           Data.Extensible
import           Data.Maybe                     (fromMaybe)
import           Data.Proxy                     (Proxy (..))
import           Whoami.Service.Data.Class      (Service (..), Uniform (..),
                                                 toInfo)
import           Whoami.Service.Data.Config     (LibConfig)
import           Whoami.Service.Data.Info       (Library (..), ServiceType)
import           Whoami.Service.Internal.Fetch  (fetchHtml)
import           Whoami.Service.Internal.Scrape (scrapeDesc)

newtype AnyLib = AnyLib LibConfig

libs :: Proxy AnyLib
libs = Proxy

instance Service AnyLib where
  genInfo _ = do
    confs <- reader (view #library)
    mapM (toInfo . AnyLib) confs

instance Uniform AnyLib where
  fetch (AnyLib conf) = fetchHtml $ conf ^. #url
  fill (AnyLib conf) html =
    pure . AnyLib $ conf & #description %~ (<|> scrapeDesc html)
  uniform (AnyLib conf) =
    pure (shrink $ #description @= desc <: #type @= libt <: conf)
    where
      desc = fromMaybe "" $ conf ^. #description
      libt :: ServiceType
      libt = embed $ #lib @= (Library $ shrink conf)
