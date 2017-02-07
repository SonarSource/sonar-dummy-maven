#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v33 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools
. installJDK8

curl -O http://repo.maven.apache.org/maven2/io/tesla/profile/tesla-profiler/0.0.3/tesla-profiler-0.0.3.jar

mkdir -p ~/maven
cp -R /usr/local/maven-3.2.5 ~/maven
export M2_HOME=~/maven/apache-maven-3.2.5
export PATH=$M2_HOME/bin:$PATH

cp tesla-profiler-0.0.3.jar ~/maven/maven-3.2.5/lib/ext

java -version

case "$TEST" in

ci)
  #deploy pull request artifacts to repox to start QA
  export DEPLOY_PULL_REQUEST=true
  regular_mvn_build_deploy_analyze -Dmaven.profile
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
