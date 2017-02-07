#!/bin/bash

set -euo pipefail

function installTravisTools {
  mkdir ~/.local
  curl -sSL https://github.com/SonarSource/travis-utils/tarball/v33 | tar zx --strip-components 1 -C ~/.local
  source ~/.local/bin/install
}

installTravisTools
. installJDK8

#download maven profile
curl -O http://repo.maven.apache.org/maven2/io/tesla/profile/tesla-profiler/0.0.3/tesla-profiler-0.0.3.jar
#copy maven to be able to install ext-lib as non root
mkdir -p ~/maven
cp -R /usr/local/maven-3.2.5 ~/maven
cp tesla-profiler-0.0.3.jar ~/maven/maven-3.2.5/lib/ext
#setup system to use mvn copy
export M2_HOME=~/maven/maven-3.2.5
export PATH=$M2_HOME/bin:$PATH


java -version

case "$TEST" in

ci)
  #deploy pull request artifacts to repox to start QA
  export DEPLOY_PULL_REQUEST=true
  if [ "${TRAVIS_BRANCH}" == "master" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo '======= Build, deploy and analyze master'

  # Fetch all commit history so that SonarQube has exact blame information
  # for issue auto-assignment
  # This command can fail with "fatal: --unshallow on a complete repository does not make sense" 
  # if there are not enough commits in the Git repository (even if Travis executed git clone --depth 50).
  # For this reason errors are ignored with "|| true"
  git fetch --unshallow || true

  # Analyze with SNAPSHOT version as long as SQ does not correctly handle
  # purge of release data
  CURRENT_VERSION=`maven_expression "project.version"`

  . set_maven_build_version $TRAVIS_BUILD_NUMBER
  
  export MAVEN_OPTS="-Xmx1536m -Xms128m"
  mvn org.jacoco:jacoco-maven-plugin:prepare-agent deploy sonar:sonar \
      -Pcoverage-per-test,deploy-sonarsource,release \
      -Dmaven.test.redirectTestOutputToFile=false \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -Dsonar.projectVersion=$CURRENT_VERSION \
      -B -e -V -Dmaven.profile $*

elif [[ "${TRAVIS_BRANCH}" == "branch-"* ]] && [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  # no dory analysis on release branch

  # Fetch all commit history so that SonarQube has exact blame information
  # for issue auto-assignment
  # This command can fail with "fatal: --unshallow on a complete repository does not make sense" 
  # if there are not enough commits in the Git repository (even if Travis executed git clone --depth 50).
  # For this reason errors are ignored with "|| true"
  git fetch --unshallow || true

  export MAVEN_OPTS="-Xmx1536m -Xms128m" 

  # get current version from pom
  CURRENT_VERSION=`maven_expression "project.version"`
  
  if [[ $CURRENT_VERSION =~ "-SNAPSHOT" ]]; then
    echo "======= Found SNAPSHOT version ======="
    # Do not deploy a SNAPSHOT version but the release version related to this build
    . set_maven_build_version $TRAVIS_BUILD_NUMBER
    mvn deploy \
      -Pdeploy-sonarsource,release \
      -B -e -V $*
  else
    echo "======= Found RELEASE version ======="
    mvn deploy \
      -Pdeploy-sonarsource,release \
      -B -e -V $*
  fi

elif [ "$TRAVIS_PULL_REQUEST" != "false" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  echo '======= Build and analyze pull request'
  
  # Do not deploy a SNAPSHOT version but the release version related to this build and PR
  . set_maven_build_version $TRAVIS_BUILD_NUMBER

  # No need for Maven phase "install" as the generated JAR files do not need to be installed
  # in Maven local repository. Phase "verify" is enough.

  export MAVEN_OPTS="-Xmx1G -Xms128m"
  if [ "${DEPLOY_PULL_REQUEST:-}" == "true" ]; then
    echo '======= with deploy'
    mvn org.jacoco:jacoco-maven-plugin:prepare-agent deploy sonar:sonar \
      -Pdeploy-sonarsource \
      -Dmaven.test.redirectTestOutputToFile=false \
      -Dsonar.analysis.mode=issues \
      -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
      -Dsonar.github.repository=$TRAVIS_REPO_SLUG \
      -Dsonar.github.oauth=$GITHUB_TOKEN \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -B -e -V $*
  else
    echo '======= no deploy'
    mvn org.jacoco:jacoco-maven-plugin:prepare-agent verify sonar:sonar \
      -Dmaven.test.redirectTestOutputToFile=false \
      -Dsonar.analysis.mode=issues \
      -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
      -Dsonar.github.repository=$TRAVIS_REPO_SLUG \
      -Dsonar.github.oauth=$GITHUB_TOKEN \
      -Dsonar.host.url=$SONAR_HOST_URL \
      -Dsonar.login=$SONAR_TOKEN \
      -B -e -V $*
  fi

else
  echo '======= Build, no analysis, no deploy'

  # No need for Maven phase "install" as the generated JAR files do not need to be installed
  # in Maven local repository. Phase "verify" is enough.

  mvn verify \
      -Dmaven.test.redirectTestOutputToFile=false \
      -B -e -V $*
fi
  ;;

*)
  echo "Unexpected TEST mode: $TEST"
  exit 1
  ;;

esac
