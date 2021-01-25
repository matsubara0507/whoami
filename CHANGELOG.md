# Changelog for whoami

## Unreleased changes

- Misc: update LTS to 17.0
- CI: change to GitHub Actions from TravisCI
- Image: use GitHub Container Registry instead of Docker Hub

## 1.0.0

- Misc: update stack.yaml for stack-2.1.1
  - update mix.hs repository commit hash
- Refactor: update lts to 14.6
  - update deps package extensible to 0.6.1
  - use githash instead of gitrev
- Misc: change image to matsubara0507/stack-build for docker integrarion
- Feat: `--help` options
- Refactor: test spec to remove tasty-discover

## 0.3.0.0

- Feat: collect medium posts by user id
- Refactor: remove dependent for shelly using threadDelay
- Refactor: use throwM instead of throwIO
- Feat: version and verbose options
- Modify: default no log

## 0.2.0.0

- use mix library
