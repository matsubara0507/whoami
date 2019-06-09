#!/bin/bash
set -eux

stack --no-terminal --install-ghc build -j 1 Cabal
stack --no-terminal build --only-dependencies
stack --no-terminal install
