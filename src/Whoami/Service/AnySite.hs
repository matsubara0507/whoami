module Whoami.Service.AnySite where

import           RIO

import           Data.Extensible
import           Whoami.Service.Data.Class     (Service (..), Uniform (..),
                                                toInfo)
import           Whoami.Service.Data.Config    (SiteConfig)
import           Whoami.Service.Data.Info      (ServiceType, Site (..))
import           Whoami.Service.Internal.Fetch (ping)

newtype AnySite = AnySite SiteConfig deriving (Show)

sites :: Proxy AnySite
sites = Proxy

instance Service AnySite where
  genInfo _ = do
    confs <- asks (view #site . view #config)
    mapM (toInfo . AnySite) confs

instance Uniform AnySite where
  fetch (AnySite conf) = ping $ conf ^. #url
  fill site _ = pure site
  uniform (AnySite conf) =
    pure (shrink $ #type @= (embed $ #site @= Site :: ServiceType) <: conf)
