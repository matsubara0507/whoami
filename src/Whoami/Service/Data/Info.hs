{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeFamilies  #-}
{-# LANGUAGE TypeOperators #-}

module Whoami.Service.Data.Info where

import           Data.Extensible
import           Data.Text       (Text)

type Info = Record
  '[ "name" >: Text
   , "url" >: Url
   , "description" >: Text
   , "type" >: ServiceType
   ]

type ServiceType = Variant
  '[ "post" >: Post
   , "app"  >: Application
   , "lib"  >: Library
   , "site" >: Site
   ]

newtype Post = Post (Record '[ "date" >: Date ]) deriving (Show, Eq)
data Application = Application deriving (Show, Eq)
newtype Library = Library (Record '[ "langage" >: Text ]) deriving (Show, Eq)
data Site = Site deriving (Show, Eq)

type Url = Text
type Date = Text
