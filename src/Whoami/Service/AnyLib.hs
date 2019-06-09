module Whoami.Service.AnyLib where

import           RIO

import           Data.Extensible
import           Whoami.Service.Data.Class      (Service (..), Uniform (..),
                                                 toInfo)
import           Whoami.Service.Data.Config     (LibConfig)
import           Whoami.Service.Data.Info       (Library (..), ServiceType)
import           Whoami.Service.Internal.Fetch  (fetchHtml)
import           Whoami.Service.Internal.Scrape (scrapeDesc)

newtype AnyLib = AnyLib LibConfig deriving (Show)

libs :: Proxy AnyLib
libs = Proxy

instance Service AnyLib where
  genInfo _ = do
    confs <- asks (view #library . view #config)
    mapM (toInfo . AnyLib) confs

instance Uniform AnyLib where
  fetch (AnyLib conf) = fetchHtml $ conf ^. #url
  fill (AnyLib conf) html =
    pure . AnyLib $ conf & #description `over` (<|> scrapeDesc html)
  uniform (AnyLib conf) =
    pure (shrink $ #description @= desc <: #type @= libt <: conf)
    where
      desc = fromMaybe "" $ conf ^. #description
      libt :: ServiceType
      libt = embed $ #lib @= (Library $ shrink conf)
