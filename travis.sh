#!/bin/bash
export SONAR_HOST_URL=localhost:9000
export SONAR_GITHUB_REPOSITORY=git@github.com:SonarSource/sonar_dummy
export TRAVIS_PULL_REQUEST=1
SONAR_GITHUB_LOGIN
SONAR_GITHUB_OAUTH

echo $SONAR_HOST_URL $SONAR_GITHUB_REPOSITORY $TRAVIS_PULL_REQUEST

mvn sonar:sonar \
 -Dsonar.analysis.mode=incremental \
 -Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
 -Dsonar.github.repository=$SONAR_GITHUB_REPOSITORY \
 -Panalysis -Dsonar.forceUpdate=true \
 -Dsonar.github.login=$SONAR_GITHUB_LOGIN \
 -Dsonar.github.oauth=$SONAR_GITHUB_OAUTH \
 -Dsonar.host.url=$SONAR_HOST_URL \
 -Dsonar.login=$SONAR_LOGIN \
 -Dsonar.password=$SONAR_PASSWORD \
 -Dsonar.jdbc.url=$SONAR_JDBC_URL \
 -Dsonar.jdbc.username=$SONAR_JDBC_USERNAME \
 -Dsonar.jdbc.password=$SONAR_JDBC_PASSWORD