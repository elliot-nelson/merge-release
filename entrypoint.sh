#!/bin/sh

set -e

if [ -n "$NPM_AUTH_TOKEN" ]; then
  # Respect NPM_CONFIG_USERCONFIG if it is provided, default to $HOME/.npmrc
  NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG-"$HOME/.npmrc"}"
  NPM_REGISTRY_URL="${NPM_REGISTRY_URL-registry.npmjs.org}"
  NPM_STRICT_SSL="${NPM_STRICT_SSL-true}"
  NPM_REGISTRY_SCHEME="https"
  if ! $NPM_STRICT_SSL
  then
    NPM_REGISTRY_SCHEME="http"
  fi

  # Allow registry.npmjs.org to be overridden with an environment variable
  printf "//%s/:_authToken=%s\\nregistry=%s\\nstrict-ssl=%s" "$NPM_REGISTRY_URL" "$NPM_AUTH_TOKEN" "${NPM_REGISTRY_SCHEME}://$NPM_REGISTRY_URL" "${NPM_STRICT_SSL}" > "$NPM_CONFIG_USERCONFIG"

  chmod 0600 "$NPM_CONFIG_USERCONFIG"
fi

if [ -n "$CUSTOM_NPM_CONFIG" ]; then
  echo "$CUSTOM_NPM_CONFIG" > "$NPM_CONFIG_USERCONFIG"
fi

# initialize git
remote_repo="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git config http.sslVerify false
git config user.name "Merge Release"
git config user.email "actions@users.noreply.github.com"
git remote add merge-release "${remote_repo}"
git remote --verbose
git show-ref # useful for debugging
git branch --verbose

#if [ "$GITHUB_REPOSITORY" = "mikeal/merge-release" ]
#then
wget https://raw.githubusercontent.com/elliot-nelson/merge-release/master/merge-release-run.js
#curl https://github.com/elliot-nelson/merge-release/blob/master/entrypoint.sh -o entrypoint.sh
  echo "node merge-release-run.js"
  sh -c "node merge-release-run.js $*"
#else
#  echo "npx merge-release"
#  sh -c "npx merge-release $*"
#fi
git push "${remote_repo}" --tags
