# whoami

Generate my "who am i" using Haskell.

## Usage

### GHCi (example)

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

### CLI

cli usage

```
whoami [options] [input-file]
  -o FILE               --output=FILE                Write output to FILE instead of stdout.
  -t FORMAT, -w FORMAT  --to=FORMAT, --write=FORMAT  Specify output format. default is `markdown`.
```

e.g. 

```
$ stack exec -- whoami -o example/whoami.md example/whoami.yaml
```
