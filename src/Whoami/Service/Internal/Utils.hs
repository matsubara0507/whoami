{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PolyKinds             #-}
{-# LANGUAGE TypeOperators         #-}
{-# OPTIONS_GHC -fno-warn-simplifiable-class-constraints #-}

module Whoami.Service.Internal.Utils where

import           Data.Extensible

embedM :: (Functor f, x ∈ xs) => Comp f h x -> f (h :| xs)
embedM = fmap embed . getComp

embedAssocM :: (Functor f, Associate k a xs) => Comp f h (k >: a) -> f (h :| xs)
embedAssocM = fmap embedAssoc . getComp

valid :: (a -> Bool) -> a -> Maybe a
valid p a = if p a then pure a else Nothing
