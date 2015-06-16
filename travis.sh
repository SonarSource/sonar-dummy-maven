echo ${sonar.host.url} ${sonar.github.repository} ${TRAVIS_PULL_REQUEST}

mvn sonar:sonar \
 -Dsonar.analysis.mode=incremental \
 -Dsonar.github.pullRequest=${TRAVIS_PULL_REQUEST} \
 -Dsonar.github.repository=${sonar.github.repository} \
 -Panalysis -Dsonar.forceUpdate=true \
 -Dsonar.github.login=${sonar.github.login} \
 -Dsonar.github.oauth=${sonar.github.oauth} \
 -Dsonar.host.url=${sonar.host.url} \
 -Dsonar.login=${sonar.login} \
 -Dsonar.password=${sonar.password} \
 -Dsonar.jdbc.url=${sonar.jdbc.url} \
 -Dsonar.jdbc.username=${sonar.jdbc.username} \
 -Dsonar.jdbc.password=${sonar.jdbc.password}