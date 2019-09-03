import os
import requests
import json

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
  print("NOT in PR")
  if os.environ['GITHUB_BRANCH'] == "master" or os.environ['GITHUB_BRANCH'].startswith("branch-"):
    print("master or release branch detected")
    privateTargetRepo='sonarsource-private-builds'
    publicTargetRepo="sonarsource-public-builds"
    status="it-passed"

print(f"status:{status}")
 
if status:
  print(f"Promoting build {os.environ['PROJECT']}#{os.environ['BUILD_NUMBER']}")
  json_payload={
      "status": f"{status}",
      "targetRepo": f"{privateTargetRepo}"
  }
  print(json_payload)
  url = f"{os.environ['ARTIFACTORY_URL']}/api/build/promote/{os.environ['PROJECT']}/{os.environ['BUILD_NUMBER']}"
  headers = {'content-type': 'application/json', 'X-JFrog-Art-Api': '{ARTIFACTORY_API_KEY}'.format(ARTIFACTORY_API_KEY=os.environ['ARTIFACTORY_API_KEY'])}
  r = requests.post(url, data=json.dumps(json_payload), headers=headers)
  print(f"promotion http_code: {r.status_code} json: {r.json} text: {r.text}")
  
else:
  print(f"status is: {status}")
"""
.format(ARTIFACTORY_URL=os.environ['ARTIFACTORY_URL'],GITHUB_REPO=os.environ['GITHUB_REPO'],BUILD_NUMBER=os.environ['BUILD_NUMBER'])  
  HTTP_CODE=$(curl -s -o /dev/null -w %{http_code} \
      -H "X-JFrog-Art-Api:${ARTIFACTORY_API_KEY}" \
      -H "Content-type: application/json" \
      "$ARTIFACTORY_URL/api/build/promote/$PROJECT/$BUILD_NUMBER" \
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