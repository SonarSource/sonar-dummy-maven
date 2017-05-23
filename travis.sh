#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v36 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools
cancel_branch_build_with_pr
. installJDK8

java -version

case "$TEST" in

ci)
  #deploy pull request artifacts to repox to start QA
  export DEPLOY_PULL_REQUEST=true  
  CURRENT_VERSION=`maven_expression "project.version"`

  . set_maven_build_version $TRAVIS_BUILD_NUMBER
  
  export MAVEN_OPTS="-Xmx1536m -Xms128m"
  regular_mvn_build_deploy_analyze -Pstats

  cat stats.log      
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
