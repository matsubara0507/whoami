{-# OPTIONS_GHC -fno-warn-simplifiable-class-constraints #-}

module Whoami.Service.Internal.Utils where

import           RIO

import           Data.Extensible

embedM :: (Functor f, x ∈ xs) => Compose f h x -> f (xs :/ h)
embedM = fmap embed . getCompose

embedAssocM :: (Functor f, Lookup xs k a) => Compose f h (k >: a) -> f (xs :/ h)
embedAssocM = fmap embedAssoc . getCompose

valid :: (a -> Bool) -> a -> Maybe a
valid p a = if p a then pure a else Nothing

sleep :: MonadIO m => Int -> m ()
sleep = liftIO . threadDelay . (* 1_000_000)
