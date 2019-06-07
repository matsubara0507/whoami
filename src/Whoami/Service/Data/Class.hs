{-# OPTIONS_GHC -fno-warn-orphans #-}

module Whoami.Service.Data.Class where

import           RIO                        hiding (Data)

import           Data.Extensible
import qualified Mix
import qualified Mix.Plugin.Config          as MixConfig
import qualified Mix.Plugin.Logger          as MixLogger
import           Network.HTTP.Req           (HttpException)
import           Whoami.Service.Data.Config (Config)
import           Whoami.Service.Data.Info   (Info)

class Service a where
  genInfo :: Proxy a -> ServiceM [Info]

class Uniform a where
  fetch :: a -> ServiceM Data
  fill :: a -> Data -> ServiceM a
  uniform :: a -> ServiceM Info

toInfo :: Uniform a => a -> ServiceM Info
toInfo conf = uniform =<< fill conf =<< fetch conf

type Data = Text

type ServiceM = RIO Env

type Env = Record
  '[ "config"  >: Config
   , "logger"  >: LogFunc
   ]

data ServiceException
  = FetchException (Either HttpException Text)
  | FillException Text
  | UniformException Text
  | ServiceException Text
  deriving (Typeable, Show, Eq)

instance Eq HttpException where
  a == b = show a == show b

instance Exception ServiceException

runServiceM :: Config -> ServiceM a -> IO (Either ServiceException a)
runServiceM config = try . Mix.run plugin
  where
    logConf = #handle @= stdout <: #verbose @= True <: nil
    plugin = hsequence
        $ #config <@=> MixConfig.buildPlugin config
       <: #logger <@=> MixLogger.buildPlugin logConf
       <: nil
