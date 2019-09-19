{-# OPTIONS_GHC -fno-warn-simplifiable-class-constraints #-}

module Whoami.Service.Internal.Utils where

import           RIO

import           Data.Extensible

embedM :: (Functor f, x ∈ xs) => Comp f h x -> f (xs :/ h)
embedM = fmap embed . getComp

embedAssocM :: (Functor f, Lookup xs k a) => Comp f h (k >: a) -> f (xs :/ h)
embedAssocM = fmap embedAssoc . getComp

valid :: (a -> Bool) -> a -> Maybe a
valid p a = if p a then pure a else Nothing

sleep :: MonadIO m => Int -> m ()
sleep = liftIO . threadDelay . (* 1_000_000)
