{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE TypeFamilies     #-}

module Whoami.Service.AnySite where

import           Control.Lens                  (view, (^.))
import           Control.Monad.Reader          (reader)
import           Data.Extensible
import           Data.Proxy                    (Proxy (..))
import           Whoami.Service.Data.Class     (Service (..), Uniform (..),
                                                toInfo)
import           Whoami.Service.Data.Config    (SiteConfig)
import           Whoami.Service.Data.Info      (ServiceType, Site (..))
import           Whoami.Service.Internal.Fetch (ping)

newtype AnySite = AnySite SiteConfig

sites :: Proxy AnySite
sites = Proxy

instance Service AnySite where
  genInfo _ = do
    confs <- reader (view #site)
    mapM (toInfo . AnySite) confs

instance Uniform AnySite where
  fetch (AnySite conf) = ping $ conf ^. #url
  fill site _ = pure site
  uniform (AnySite conf) =
    pure (shrink $ #type @= (embed $ #site @= Site :: ServiceType) <: conf)
