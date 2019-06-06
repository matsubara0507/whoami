module Whoami.Service.Data.Config where

import           RIO

import           Data.Extensible
import           Whoami.Service.Data.Info (Date, Url)

type Config = Record
  '[ "name"    >: Text
   , "account" >: Accounts
   , "site"    >: [SiteConfig]
   , "post"    >: Record '[ "latest" >: Maybe Int, "posts" >: [PostConfig]]
   , "library" >: [LibConfig]
   , "app"     >: [AppConfig]
   , "qiita"   >: QiitaConfig
   , "medium"  >: MediumConfig
   ]

type Accounts = Map Text Text

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
   , "count" >: Maybe Int
   ]

type MediumConfig = QiitaConfig
