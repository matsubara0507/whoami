{-# LANGUAGE OverloadedLabels  #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}

module Whoami.Service.AnyApp where

import           RIO

import           Data.Extensible
import           Whoami.Service.Data.Class      (Service (..), Uniform (..),
                                                 toInfo)
import           Whoami.Service.Data.Config     (AppConfig)
import           Whoami.Service.Data.Info       (Application (..), ServiceType)
import           Whoami.Service.Internal.Fetch  (fetchHtml)
import           Whoami.Service.Internal.Scrape (scrapeDesc)

newtype AnyApp = AnyApp AppConfig

apps :: Proxy AnyApp
apps = Proxy

instance Service AnyApp where
  genInfo _ = do
    confs <- asks (view #app . view #config)
    mapM (toInfo . AnyApp) confs

instance Uniform AnyApp where
  fetch (AnyApp conf) = fetchHtml $ conf ^. #url
  fill (AnyApp conf) html =
    pure . AnyApp $ conf & #description `over` (<|> scrapeDesc html)
  uniform (AnyApp conf) =
    pure (shrink $ #description @= desc <: #type @= appt <: conf)
    where
      desc = fromMaybe "" $ conf ^. #description
      appt :: ServiceType
      appt = embed $ #app @= Application
