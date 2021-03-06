module Whoami.Service.Data.Info where

import           RIO

import           Data.Extensible
import           Data.Kind            (Type)
import           Text.Megaparsec      (Parsec, count, parseMaybe)
import           Text.Megaparsec.Char (char, digitChar)

type Info = Record
  '[ "name" >: Text
   , "url" >: Url
   , "description" >: Text
   , "type" >: ServiceType
   ]

type ServiceType = Variant ServiceTypeFields

type ServiceTypeFields =
  '[ "post" >: Post
   , "app"  >: Application
   , "lib"  >: Library
   , "site" >: Site
   ]

isPost, isApp, isLib, isSite :: Info -> Bool
isPost = isServiceType #post . view #type
isApp  = isServiceType #app  . view #type
isLib  = isServiceType #lib  . view #type
isSite = isServiceType #site . view #type

isServiceType ::
  forall v1 (h :: v1 -> Type) (v4 :: v1) b1 (v5 :: v1) b2 (v6 :: v1) b3 (v7 :: v1) b4 a b5.
  ( Repr h v7 ~ (b4 -> Bool), Repr h v6 ~ (b3 -> Bool)
  , Repr h v5 ~ (b2 -> Bool), Repr h v4 ~ (b1 -> Bool), Wrapper h) =>
  ASetter
    ('["post" ':> v5, "app" ':> v4, "lib" ':> v7, "site" ':> v6] :& Field h)
    (RecordOf (Match Identity Bool) ServiceTypeFields) a (b5 -> Bool)
  -> ServiceType
  -> Bool
isServiceType l = matchField (m & l `set` const True)
  where
    m = #post @= const False
     <: #app  @= const False
     <: #lib  @= const False
     <: #site @= const False
     <: nil

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
  y <- fromString <$> count 4 digitChar
  _ <- char '-'
  m <- fromString <$> count 2 digitChar
  _ <- char '-'
  d <- fromString <$> count 2 digitChar
  return $ mconcat [y, "-", m, "-", d]

getDate :: Info -> Date
getDate = matchField m . view #type
  where
    m = #post @= (\(Post conf) -> conf ^. #date)
     <: #app  @= const ""
     <: #lib  @= const ""
     <: #site @= const ""
     <: nil
