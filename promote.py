import os
import requests
import json

pullRequest=os.environ['PULL_REQUEST']
githubBranch=os.environ['GITHUB_BRANCH']
githubrepo=os.environ['GITHUB_REPO']
buildNumer=os.environ['BUILD_NUMBER']
artifactoryUrl=os.environ['ARTIFACTORY_URL']
project=os.environ['PROJECT']
artifactoryApiKey=os.environ['ARTIFACTORY_API_KEY']
privateTargetRepo=None
publicTargetRepo=None
status=None

print("PULL_REQUESTinPR: " + pullRequest)
print("GITHUB_BRANCH: " + githubBranch)
print("GITHUB_REPO: " + githubrepo)
print("BUILD_NUMBER: " + buildNumer)


if pullRequest:
  print("in PR")
  privateTargetRepo='sonarsource-private-dev'
  publicTargetRepo="sonarsource-public-dev"
  status="it-passed-pr"
else:
  print("NOT in PR")
  if githubBranch == "master" or githubBranch.startswith("branch-"):
    print("master or release branch detected")
    privateTargetRepo='sonarsource-private-builds'
    publicTargetRepo="sonarsource-public-builds"
    status="it-passed"

print(f"status:{status}")
 
if status:
  print(f"Promoting build {project}#{buildNumer}")
  json_payload={
      "status": f"{status}",
      "targetRepo": f"{privateTargetRepo}"
  }
  print(json_payload)
  url = f"{artifactoryUrl}/api/build/promote/{project}/{buildNumer}"
  headers = {'content-type': 'application/json', 'X-JFrog-Art-Api': '{ARTIFACTORY_API_KEY}'.format(ARTIFACTORY_API_KEY=artifactoryApiKey)}
  r = requests.post(url, data=json.dumps(json_payload), headers=headers)
  print(f"promotion http_code: {r.status_code} json: {r.json} text: {r.text}")
  
else:
  print(f"status is: {status}")
