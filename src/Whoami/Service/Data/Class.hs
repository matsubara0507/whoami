{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Whoami.Service.Data.Class where

import           Data.Extensible
import           Data.Extensible.Effect.Default (EitherDef, ReaderDef,
                                                 runReaderDef)
import           Data.Extensible.Effect.Logger
import           Data.Proxy                     (Proxy)
import           Data.Text                      (Text)
import           Network.HTTP.Req               (HttpException)
import           Whoami.Service.Data.Config     (Config)
import           Whoami.Service.Data.Info       (Info)

class Service a where
  genInfo :: Proxy a -> ServiceM [Info]

class Uniform a where
  fetch :: a -> ServiceM Data
  fill :: a -> Data -> ServiceM a
  uniform :: a -> ServiceM Info

toInfo :: Uniform a => a -> ServiceM Info
toInfo conf = uniform =<< fill conf =<< fetch conf

type Data = Text

type ServiceM = Eff
  '[ ReaderDef Config
   , EitherDef UniformException
   , LoggerDef
   , "IO" >: IO
   ]

data UniformException
  = FetchException (Either HttpException Text)
  | FillException Text
  | UniformException Text
  deriving (Show, Eq)

instance Eq HttpException where
  a == b = show a == show b

runServiceM :: Config -> ServiceM a -> IO (Either UniformException a)
runServiceM config =
  retractEff . runLoggerDef . runEitherEff . flip runReaderDef config
