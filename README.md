# whoami

Generate my "who am i" using Haskell.

## Usage

### GHCi (example)

```
$ stack ghci
>> import RIO
>> import Data.Yaml
>> (Right conf) <- decodeFileEither "example/whoami.yaml" :: IO (Either ParseException Config)
>> (Right txt) <- runServiceM conf $ toMarkdown =<< genInfo whoami
...
```

### CLI

cli usage

```
whoami [options] [input-file]
  -o FILE               --output=FILE                Write output to FILE instead of stdout.
  -t FORMAT, -w FORMAT  --to=FORMAT, --write=FORMAT  Specify output format. default is `markdown`.
  -v                    --verbose                    Enable verbose mode: verbosity level "debug"
                        --version                    Show version
```

e.g.

```
$ stack exec -- whoami -o example/whoami.md example/whoami.yaml
```
