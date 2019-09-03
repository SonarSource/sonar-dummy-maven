import os

print("PULL_REQUEST: " + os.environ['PULL_REQUEST'])
print("GITHUB_BRANCH: " + os.environ['GITHUB_BRANCH'])
print("GITHUB_REPO: " + os.environ['GITHUB_REPO'])
print("BUILD_NUMBER: " + os.environ['BUILD_NUMBER'])
"""
if os.environ['PULL_REQUEST']:
  PRIVATE_TARGET_REPO='sonarsource-private-dev'
  PUBLIC_TARGET_REPO="sonarsource-public-dev"
  STATUS="it-passed-pr"
else:
  if [[ "$GITHUB_BRANCH" == "master" ]] || [[ "$GITHUB_BRANCH" == "branch-"* ]]; then
    PRIVATE_TARGET_REPO='sonarsource-private-builds'
    PUBLIC_TARGET_REPO="sonarsource-public-builds"
    STATUS="it-passed"
  fi
fi

if [[ "${STATUS:-}" ]]; then
  echo "Promoting build $CIRRUS_REPO_NAME#$BUILD_NUMBER"
  json_payload='{
      "status": "'"$STATUS"'",
      "targetRepo": "'"$PUBLIC_TARGET_REPO"'"
    }'
  HTTP_CODE=$(curl -s -o /dev/null -w %{http_code} \
      -H "X-JFrog-Art-Api:${ARTIFACTORY_API_KEY}" \
      -H "Content-type: application/json" \
      "$ARTIFACTORY_URL/api/build/promote/$CIRRUS_REPO_NAME/$BUILD_NUMBER" \
      -d "$json_payload")
  if [[ "$HTTP_CODE" != "200" ]]; then
    echo "Cannot promote build $CIRRUS_REPO_NAME#$BUILD_NUMBER: ($HTTP_CODE)"
    exit 1
  else
    echo "Build ${CIRRUS_REPO_NAME}#${BUILD_NUMBER} promoted to ${PRIVATE_TARGET_REPO} and ${PUBLIC_TARGET_REPO}"
    ./cirrus/burgr-notify-promotion.sh
  fi
else
  echo "No promotion for builds coming from a development branch"
fi
"""