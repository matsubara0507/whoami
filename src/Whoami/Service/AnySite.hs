{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TypeFamilies     #-}

module Whoami.Service.AnySite where

import           Control.Lens                  ((^.))
import           Data.Extensible
import           Whoami.Service.Data.Class     (Service (..))
import           Whoami.Service.Data.Config    (SiteConfig)
import           Whoami.Service.Data.Info      (ServiceType, Site (..))
import           Whoami.Service.Internal.Fetch (ping)

newtype AnySite = AnySite SiteConfig

instance Service AnySite where
  fetch (AnySite conf) = ping $ conf ^. #url
  fill site _ = pure site
  uniform (AnySite conf) =
    pure (shrink $ #type @= (embed $ #site @= Site :: ServiceType) <: conf)
