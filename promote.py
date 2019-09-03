import os

print("PULL_REQUESTinPR: " + os.environ['PULL_REQUEST'])
print("GITHUB_BRANCH: " + os.environ['GITHUB_BRANCH'])
print("GITHUB_REPO: " + os.environ['GITHUB_REPO'])
print("BUILD_NUMBER: " + os.environ['BUILD_NUMBER'])

privateTargetRepo=None
publicTargetRepo=None
status=None

if os.environ['PULL_REQUEST']:
  print("in PR")
  privateTargetRepo='sonarsource-private-dev'
  publicTargetRepo="sonarsource-public-dev"
  status="it-passed-pr"
else:
  if os.environ['GITHUB_BRANCH'] == "master" or os.environ['GITHUB_BRANCH'].startswith("branch-"):
    print("NOT in PR")
    privateTargetRepo='sonarsource-private-builds'
    publicTargetRepo="sonarsource-public-builds"
    status="it-passed"

print(status)

"""  
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