{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeOperators     #-}

module Whoami.Service.Data.Info where

import           Data.Extensible
import           Data.Maybe           (isJust)
import           Data.Text            (Text, pack)
import           Text.Megaparsec      (Parsec, count, parseMaybe)
import           Text.Megaparsec.Char (char, digitChar)

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
newtype Library = Library (Record '[ "language" >: Text ]) deriving (Show, Eq)
data Site = Site deriving (Show, Eq)

type Url = Text
type Date = Text

validDate :: Date -> Bool
validDate = isJust . parseMaybe dateParser

-- parse "yyyy-mm-dd"
dateParser :: Parsec String Text Date
dateParser = do
  y <- pack <$> count 4 digitChar
  _ <- char '-'
  m <- pack <$> count 2 digitChar
  _ <- char '-'
  d <- pack <$> count 2 digitChar
  return $ mconcat [y, "-", m, "-", d]
