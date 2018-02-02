{-# LANGUAGE DataKinds     #-}
{-# LANGUAGE TypeFamilies  #-}
{-# LANGUAGE TypeOperators #-}

module Whoami.Service.Data.Config where

import           Data.Extensible
import           Data.Map                 (Map)
import           Data.Text                (Text)
import           Whoami.Service.Data.Info (Date, Url)

type Config = Record
  '[ "name"    >: Text
   , "account" >: Map Text Url
   , "site"    >: [SiteConfig]
   , "post"    >: Record '[ "latest" >: Maybe Int, "posts" >: [PostConfig]]
   , "library" >: [LibConfig]
   , "app"     >: [AppConfig]
   , "qiita"   >: QiitaConfig
   ]

type SiteConfig = Record
  '[ "name" >: Text
   , "url"  >: Url
   , "description" >: Text
   ]

type PostConfig = Record
  '[ "title" >: Maybe Text
   , "url"  >: Url
   , "date" >: Maybe Date
   ]

type LibConfig = Record
  '[ "name" >: Text
   , "url"  >: Url
   , "description" >: Maybe Text
   , "language" >: Text
   ]

type AppConfig = Record
  '[ "name" >: Text
   , "url"  >: Url
   , "description" >: Maybe Text
   ]

type QiitaConfig = Record
  '[ "posts" >: Maybe Bool
   ]
