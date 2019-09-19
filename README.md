# whoami

[![Build Status](https://travis-ci.org/matsubara0507/whoami.svg?branch=master)](https://travis-ci.org/matsubara0507/whoami)
[![](https://images.microbadger.com/badges/image/matsubara0507/whoami.svg)](https://microbadger.com/images/matsubara0507/whoami "Get your own image badge on microbadger.com")

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
$ whoami --help
whoami [options] [input-file]
  -o FILE               --output=FILE                Write output to FILE instead of stdout.
  -t FORMAT, -w FORMAT  --to=FORMAT, --write=FORMAT  Specify output format. default is `markdown`.
  -v                    --verbose                    Enable verbose mode: verbosity level "debug"
                        --version                    Show version
  -h                    --help                       Show this help text
```

e.g.

```
$ stack exec -- whoami -o example/whoami.md example/whoami.yaml
```

if use docker image matsubara0507/whoami

```
$ docker run --rm -v `pwd`/example:/root/work matsubara0507/whoami -o whoami.md whoami.yaml
```

## Dev

### Build Docker Image

```
$ stack --docker build -j 1 Cabal # if out of memory in docker
$ stack --docker --local-bin-path=./bin install
$ docker build -t matsubara0507/whoami . --build-arg local_bin_path=./bin
```
