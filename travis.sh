#!/bin/sh
if [ -n "$SONAR_GITHUB_OAUTH" ] && [ "${TRAVIS_PULL_REQUEST}" != "false" ] 
then
 echo "Start pullrequest analysis"
 mvn sonar:sonar \
 -Dsonar.analysis.mode=preview \
 -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
 -Dsonar.github.repository=$SONAR_GITHUB_REPOSITORY \
 -Dsonar.forceUpdate=true \
 -Dsonar.github.login=$SONAR_GITHUB_LOGIN \
 -Dsonar.github.oauth=$SONAR_GITHUB_OAUTH \
 -Dsonar.host.url=$SONAR_HOST_URL \
 -Dsonar.login=$SONAR_LOGIN \
 -Dsonar.password=$SONAR_PASSWD 
fi 
