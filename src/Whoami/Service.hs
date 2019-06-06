module Whoami.Service
  ( module X
  , Whoami
  , whoami
  ) where

import           RIO

import           Whoami.Service.AnyApp      as X
import           Whoami.Service.AnyLib      as X
import           Whoami.Service.AnyPost     as X
import           Whoami.Service.AnySite     as X
import           Whoami.Service.Data.Class  as X
import           Whoami.Service.Data.Config as X
import           Whoami.Service.Data.Info   as X
import           Whoami.Service.Medium      as X (Medium, MediumPost, medium)
import           Whoami.Service.Qiita       as X (Qiita, QiitaPost, qiita)

data Whoami

whoami :: Proxy Whoami
whoami = Proxy

instance Service Whoami where
  genInfo _ = mconcat <$> sequence
    [ genInfo sites
    , genInfo posts
    , genInfo libs
    , genInfo apps
    , genInfo qiita
    , genInfo medium
    ]
