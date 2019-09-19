#!/bin/bash
set -eux

# setup ssh-agent and provide the GitHub deploy key
eval "$(ssh-agent -s)"
openssl aes-256-cbc -K $encrypted_d876809ab7c8_key -iv $encrypted_d876809ab7c8_iv -in .travis/id_rsa.enc -out .travis/id_rsa -d
chmod 600 .travis/id_rsa
ssh-add .travis/id_rsa

# commit the assets in docs/ if changed, and push to GitHub using SSH
git config user.name "${GIT_NAME}"
git config user.email "${GIT_EMAIL}"
git clone -b gh-pages git@github.com:${TRAVIS_REPO_SLUG}.git temp

# exec whoami
cd temp
docker run --rm -v `pwd`:/work $TRAVIS_REPO_SLUG whoami -o README.md -t markdown whoami.yaml

# update gh-pages
git status
git add -A
git diff --quiet && git diff --staged --quiet || git commit -m "[skip ci] Update whoami"
git push origin gh-pages
