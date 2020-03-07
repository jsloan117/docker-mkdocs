#!/bin/bash
# build and deploy documentation using mkdocs
# TODO: prevent unnessary building by comparing remote gh-pages branch -- (git diff ignore sitemap.xml.gz)

set -euo pipefail

REPO=$(git config remote.origin.url)
SSH_REPO="${REPO/https:\/\/github.com\//git@github.com:}"
GIT_USER_NAME='Travis CI'

build_documentation () {
  mkdir -p "${HOME}/.ssh"
  echo "${DEPLOY_KEY}" | base64 --decode > "${HOME}/.ssh/id_rsa" 2>&-
  chmod 600 "${HOME}/.ssh/id_rsa"
  echo -e '\n<<< Setting remote origin to SSH >>>'
  git remote set-url origin "${SSH_REPO}"
  echo -e '\n<<< Setting Git name for commits >>>'
  git config --global user.name "${GIT_USER_NAME}"
  echo -e '\n<<< Installing mkdocs & theme >>>'
  pip3 -q install mkdocs mkdocs-material pygments
  echo ''
  #mkdocs build -cs
  mkdocs gh-deploy -cm "Deployed {sha} with MkDocs version {version}. [skip ci]" --force
  echo ''
  rm -f "${HOME}/.ssh/id_rsa"
}

build_documentation
