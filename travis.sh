#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir -p ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v54 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools
cancel_branch_build_with_pr || if [[ $? -eq 1 ]]; then exit 0; fi
. installJDK8

#deploy pull request artifacts to Artifactory to start QA
export DEPLOY_PULL_REQUEST=true

export MAVEN_OPTS="-Xmx1536m -Xms128m"
regular_mvn_build_deploy_analyze -Pstats
