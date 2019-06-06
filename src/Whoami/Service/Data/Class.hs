{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE FlexibleContexts     #-}
{-# LANGUAGE FlexibleInstances    #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Whoami.Service.Data.Class where

import           Control.Monad.IO.Class
import           Control.Monad.Logger
import           Data.Extensible
import           Data.Extensible
import           Data.Extensible.Effect.Default (EitherDef, ReaderDef,
                                                 runReaderDef)
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
   , EitherDef ServiceException
   , LoggerDef
   , "IO" >: IO
   ]

data ServiceException
  = FetchException (Either HttpException Text)
  | FillException Text
  | UniformException Text
  | ServiceException Text
  deriving (Show, Eq)

instance Eq HttpException where
  a == b = show a == show b

runServiceM :: Config -> ServiceM a -> IO (Either ServiceException a)
runServiceM config =
  retractEff . runLoggerDef . runEitherEff . flip runReaderDef config

-- Orphans

type Logging = LoggingT IO
type LoggerDef = "Logger" >: Logging

runLoggerDef :: (MonadIO (Eff xs)) => Eff (LoggerDef ': xs) a -> Eff xs a
runLoggerDef = peelEff0 pure $ \m k -> k =<< liftIO (runStdoutLoggingT m)

instance (Associate "Logger" Logging xs) => MonadLogger (Eff xs) where
  monadLoggerLog loc ls level msg =
    liftEff (Proxy :: Proxy "Logger") $ monadLoggerLog loc ls level msg
