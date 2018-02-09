# whoami

Generate my "who am i" using Haskell.

## Usage on GHCi (example)

```
$ stack ghci
>> import Data.Extensible.Instances.Aeson
>> import Data.Yaml
>> import Control.Lens ((^.))
>> (Right conf) <- decodeFileEither "example/whoami.yaml" :: IO (Either ParseException Config)
>> (Right txt) <- runServiceM conf $ toMarkdown =<< genInfo whoami
>> T.putStrLn txt
...
```
