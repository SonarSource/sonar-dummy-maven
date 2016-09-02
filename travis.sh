#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/latest | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools
. installJDK8

java -version

case "$TEST" in

ci)
  #deploy pull request artifacts to repox to start QA
  export DEPLOY_PULL_REQUEST=true
  regular_mvn_build_deploy_analyze  
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac

echo $TRAVIS
echo $TRAVIS_BUILD_NUMBER
echo $TRAVIS_COMMIT
echo $TRAVIS_PULL_REQUEST
echo $TRAVIS_BRANCH
echo $TRAVIS_REPO_SLUG
